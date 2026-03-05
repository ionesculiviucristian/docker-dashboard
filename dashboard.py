import importlib
import sys

from library.bitwarden import import_data
from library.config import config
from library.docker import Docker
from library.env import envs, sync_env_file
from library.logger import logger
from library.service_deployer import ServiceDeployer
from library.mkcert import Mkcert
from library.setup import check_requirements, run_cmd
from library.sudo import acquire as acquire_sudo


def load_deployer(service: str) -> ServiceDeployer:
    try:
        module = importlib.import_module(f"services.{service}.deploy")
    except ModuleNotFoundError:
        module = importlib.import_module(f"custom_services.{service}.deploy")
    return module.Deploy(service)


def setup():
    logger.info("Setup dashboard...")

    check_requirements()

    acquire_sudo()

    Mkcert.install_ca()

    Mkcert.create_certificate(envs.get("SERVICES_DOMAIN_NAME"))
    Mkcert.create_certificate(envs.get("PROJECTS_DOMAIN_NAME"))

    deployers: list[ServiceDeployer] = []

    for service in config.services:
        logger.info(f"Pre-deploying {service!r}...")
        deployer = load_deployer(service)
        deployer.pre_deploy()
        deployers.append(deployer)

    Docker.start_containers([f for d in deployers for f in d.get_compose_files()], remove_orphans=True)

    for deployer in deployers:
        logger.info(f"Post-deploying {deployer.name!r}...")
        deployer.post_deploy()


def start():
    logger.info("Starting dashboard...")

    files = [f for s in config.services for f in load_deployer(s).get_compose_files()]
    if not files:
        logger.info("No services to start")
        return

    Docker.start_containers(files, remove_orphans=True)

    logger.info("Start finished")


def update():
    logger.info("Updating dashboard...")

    sync_env_file(envs)
    files = [f for s in config.services for f in load_deployer(s).get_compose_files()]
    Docker.start_containers(files, remove_orphans=True)
    run_cmd("docker system prune -af")


def stop():
    logger.info("Stopping dashboard...")

    files = [f for s in config.services for f in load_deployer(s).get_compose_files()]
    if not files:
        logger.info("No services to stop")
        return

    Docker.stop_containers(files)


def restart():
    logger.info("Restarting dashboard...")

    stop()
    start()


def reset():
    confirm = input("Are you sure you want to reset dashboard services? (y/N): ")
    if confirm.lower() != "y":
        return

    logger.info("Resetting dashboard...")

    Docker.reset_containers()


def bitwarden_import():
    if len(sys.argv) < 3:
        logger.error("Usage: dashboard.py bitwarden:import <email>")
        sys.exit(1)

    import_data(sys.argv[2])


commands = {
    "setup": setup,
    "start": start,
    "update": update,
    "stop": stop,
    "restart": restart,
    "reset": reset,
    "bitwarden:import": bitwarden_import,
}


def main():
    command = sys.argv[1] if len(sys.argv) > 1 else "deploy"

    if command not in commands:
        logger.error(f"Unknown command {command!r}. Available: {', '.join(commands)}")
        sys.exit(1)

    commands[command]()


if __name__ == "__main__":
    main()
