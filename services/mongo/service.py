from library.docker import Docker


class Mongo:
    @staticmethod
    def wait_until_ready(timeout: int = 60) -> None:
        Docker.wait_for_container("mongo", "mongosh --eval \"db.adminCommand('ping')\"", timeout)
