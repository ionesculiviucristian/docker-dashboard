from library.service_deployer import ServiceDeployer


class Deploy(ServiceDeployer):
    def pre_deploy(self):
        self.envs.generate(
            "N8N_INSTANCE_OWNER_PASSWORD_HASH",
            method="hash",
            source=self.envs.get("SERVICES_USER_PASSWORD"),
            custom=True,
        )
        self.register_hostname(self.envs.get("N8N_HOSTNAME"))
