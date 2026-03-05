from library.docker import docker


class Mongo:
    @staticmethod
    def wait(timeout: int = 60) -> None:
        docker.containers.wait_for("mongo", timeout)
