import os

from library.docker import Docker
from library.service_deployer import ServiceDeployer
from library.setup import run_cmd
from services.mongo.service import Mongo


class Deploy(ServiceDeployer):
    def pre_deploy(self):
        self._create_keyfile()
        self.register_hostname(self.envs.get("MONGO_EXPRESS_HOSTNAME"))
        Docker.create_network(self.envs.get("MONGO_NETWORK"))

    def post_deploy(self):
        Mongo.wait_until_ready()
        self._init_replica()

    def _init_replica(self):
        self.logger.info("Initiating replica set...")

        user = self.envs.get("SERVICES_USER")
        password = self.envs.get("SERVICES_USER_PASSWORD")

        result = Docker.exec(
            "mongo",
            f'mongosh -u "{user}" -p "{password}" --quiet --eval "try {{ rs.conf()._id }} catch (e) {{ \'none\' }}"',
        )
        if result.stdout.strip() == "rs0":
            self.logger.debug("Replica set is already initiated")
            return

        Docker.exec(
            "mongo",
            f'mongosh -u "{user}" -p "{password}" '
            '--eval \'rs.initiate({ _id: "rs0", members: [{ _id: 0, host: "mongo:27017" }] })\'',
        )

    def _create_keyfile(self):
        self.logger.debug("Generating keyfile...")

        keyfile = "./services/mongo/keyfile"
        if os.path.isfile(keyfile):
            self.logger.debug("Keyfile already generated")
            return

        run_cmd(f"openssl rand -base64 756 > {keyfile} && chmod 400 {keyfile} && sudo chown 999:999 {keyfile}")
