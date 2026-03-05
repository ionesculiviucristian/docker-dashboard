import json
from typing import TypedDict

from library.docker import Docker
from library.service_deployer import ServiceDeployer


class S3Credential(TypedDict):
    accessKey: str
    secretKey: str


class S3Identity(TypedDict):
    name: str
    credentials: list[S3Credential]
    actions: list[str]


class S3Config(TypedDict):
    identities: list[S3Identity]


class Deploy(ServiceDeployer):
    def pre_deploy(self):
        self._create_s3_config()
        self.register_hostname(self.envs.get("SEAWEEDFS_HOSTNAME"))
        Docker.create_network(self.envs.get("SEAWEEDFS_NETWORK"))

    def _create_s3_config(self):
        s3_config: S3Config = {
            "identities": [
                {
                    "name": "admin",
                    "credentials": [
                        {
                            "accessKey": self.envs.get("SEAWEEDFS_S3_ACCESS_KEY"),
                            "secretKey": self.envs.get("SEAWEEDFS_S3_SECRET_KEY"),
                        }
                    ],
                    "actions": ["Admin", "Read", "Write", "List", "Tagging"],
                }
            ]
        }

        with open("./services/seaweedfs/s3.json", "w") as f:
            json.dump(s3_config, f, indent=2)
            f.write("\n")

        self.logger.debug("Created S3 config")
