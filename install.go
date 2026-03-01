package main

import (
	"fmt"
	"os"
	"sort"
	"strings"
	"time"

	"charm.land/bubbles/v2/paginator"
	"charm.land/bubbles/v2/spinner"
	tea "charm.land/bubbletea/v2"
	"charm.land/lipgloss/v2"
	"github.com/goccy/go-yaml"
)

type Config struct {
	Services map[string]bool `yaml:"services"`
}

type styles struct {
	activeDot   lipgloss.Style
	inactiveDot lipgloss.Style
}

type installState int

const (
	notInstalled installState = iota
	installing
	installed
)

type service struct {
	name    string
	enabled bool
	state   installState
}

type model struct {
	services  []service
	paginator paginator.Model
	spinner   spinner.Model
	quitting  bool
}

type installDoneMsg struct{ name string }

func installCmd(s service) tea.Cmd {
	return func() tea.Msg {
		time.Sleep(2 * time.Second)
		return installDoneMsg{name: s.name}
	}
}

func newStyles(bgIsDark bool) (s styles) {
	lightDark := lipgloss.LightDark(bgIsDark)

	s.activeDot = lipgloss.NewStyle().Foreground(lightDark(lipgloss.Color("235"), lipgloss.Color("252"))).SetString("•")
	s.inactiveDot = s.activeDot.Foreground(lightDark(lipgloss.Color("250"), lipgloss.Color("238"))).SetString("•")
	return s
}

func (m *model) Init() tea.Cmd {
	return m.spinner.Tick
}

func (m *model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.BackgroundColorMsg:
		m.updateStyles(msg.IsDark())
		return m, nil
	case tea.KeyPressMsg:
		switch msg.String() {
		case "q", "esc", "ctrl+c":
			m.quitting = true
			return m, tea.Quit
		case "i":
			for i, s := range m.services {
				if s.enabled {
					m.services[i].state = installing
					return m, installCmd(s)
				}
			}
		}
	case installDoneMsg:
		if m.quitting {
			return m, nil
		}
		for i, s := range m.services {
			if s.name == msg.name {
				m.services[i].state = installed
				for j := i + 1; j < len(m.services); j++ {
					if m.services[j].enabled && m.services[j].state == notInstalled {
						m.services[j].state = installing
						page := j / m.paginator.PerPage
						m.paginator.Page = page
						return m, installCmd(m.services[j])
					}
				}
			}
		}
	}
	var cmds []tea.Cmd
	var cmd tea.Cmd
	m.paginator, cmd = m.paginator.Update(msg)
	cmds = append(cmds, cmd)
	m.spinner, cmd = m.spinner.Update(msg)
	cmds = append(cmds, cmd)
	return m, tea.Batch(cmds...)
}

func (m *model) View() tea.View {
	var b strings.Builder
	b.WriteString("\n  Docker dashoard installer\n\n")
	start, end := m.paginator.GetSliceBounds(len(m.services))

	dim := lipgloss.NewStyle().Faint(true)
	green := lipgloss.NewStyle().Foreground(lipgloss.Color("2"))

	for _, service := range m.services[start:end] {
		if !service.enabled {
			b.WriteString("  ✗ " + dim.Render(service.name) + "\n")
		} else if service.state == installing {
			b.WriteString("  " + m.spinner.View() + service.name + "\n")
		} else if service.state == installed {
			b.WriteString(green.Render("  ✓ "+service.name) + "\n")
		} else {
			b.WriteString("  ✓ " + service.name + "\n")
		}

	}
	b.WriteString("  " + m.paginator.View())
	b.WriteString("\n\n  h/l ←/→ page • q: quit\n")
	return tea.NewView(b.String())
}

func newModel(config Config) model {
	services := make([]service, 0, len(config.Services))
	for k := range config.Services {
		services = append(services, service{k, config.Services[k], notInstalled})
	}

	sort.Slice(services, func(i, j int) bool {
		return services[i].name < services[j].name
	})

	p := paginator.New()
	p.Type = paginator.Dots
	p.PerPage = 10
	p.SetTotalPages(len(services))

	s := spinner.New()
	s.Spinner = spinner.Dot

	m := model{
		paginator: p,
		services:  services,
		spinner:   s,
	}

	m.updateStyles(true)
	return m
}

func (m *model) updateStyles(isDark bool) {
	styles := newStyles(isDark)
	m.paginator.ActiveDot = styles.activeDot.String()
	m.paginator.InactiveDot = styles.inactiveDot.String()
}

func loadConfig() (Config, error) {
	var config Config
	var configPaths = []string{"config.custom.yml", "config.yml"}

	for _, configPath := range configPaths {
		data, err := os.ReadFile(configPath)
		if err != nil {
			continue
		}
		if err := yaml.Unmarshal(data, &config); err != nil {
			return Config{}, fmt.Errorf("unable to decode %s: %s", configPath, err)
		}
		return config, nil
	}

	if len(config.Services) == 0 {
		return Config{}, fmt.Errorf("no config file found")
	}

	return config, nil
}

func install_service(service service) {
	service.state = installing
	time.Sleep(2 * time.Second)
	service.state = installed
}

func main() {
	config, err := loadConfig()

	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	m := newModel(config)
	p := tea.NewProgram(&m)
	if _, err := p.Run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	if m.quitting {
		os.Exit(0)
	}

	for k := range config.Services {
		install_service(service{k, config.Services[k], notInstalled})
	}
}
