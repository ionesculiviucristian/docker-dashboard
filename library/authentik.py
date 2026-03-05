import json
import ssl
import time
import urllib.error
import urllib.parse
import urllib.request
from typing import Any, Literal, Self, TypedDict, Unpack, cast, overload

from .env import envs

type Filters = dict[str, str]
type Body = dict[str, Any]
type Response = dict[str, Any]

EMBEDDED_OUTPOST = "authentik Embedded Outpost"

DEFAULT_AUTHORIZATION_FLOW = "default-provider-authorization-implicit-consent"
DEFAULT_INVALIDATION_FLOW = "default-provider-invalidation-flow"
DEFAULT_SIGNING_KEY = "authentik Self-signed Certificate"


class RedirectURI(TypedDict):
    matching_mode: str
    url: str


class ProxyProviderFields(TypedDict, total=False):
    mode: str
    authorization_flow: int
    invalidation_flow: int
    external_host: str
    internal_host: str
    internal_host_ssl_validation: bool
    cookie_domain: str
    intercept_header_auth: bool
    access_token_validity: str
    refresh_token_validity: str
    redirect_uris: list[RedirectURI]


class OAuth2ProviderFields(TypedDict, total=False):
    client_type: str
    client_id: str
    authorization_flow: int
    invalidation_flow: int
    signing_key: int
    property_mappings: list[int]
    redirect_uris: list[RedirectURI]
    access_token_validity: str
    refresh_token_validity: str


class ApplicationFields(TypedDict, total=False):
    name: str
    provider: int
    policy_engine_mode: str
    meta_launch_url: str


class FlowFields(TypedDict, total=False):
    designation: str
    name: str
    title: str
    authentication: str


class _Resource:
    def __init__(self, data: Response):
        self._data = data

    @property
    def pk(self) -> int:
        return cast(int, self._data["pk"])


class _OAuth2Provider(_Resource):
    @property
    def client_secret(self) -> str:
        return cast(str, self._data["client_secret"])


class _Manager:
    def __init__(self, api: AuthentikAPI):
        self._api = api


class _FlowManager(_Manager):
    path = "/flows/instances/"

    def ensure(self, slug: str, **fields: Unpack[FlowFields]) -> _Resource:
        data = self._api.get(self.path, {"slug": slug}) or self._api.create(self.path, {"slug": slug, **fields})
        return _Resource(data)

    def ensure_default_authorization(self) -> _Resource:
        return self.ensure(
            DEFAULT_AUTHORIZATION_FLOW,
            designation="authorization",
            name="Authorize Application",
            title="Redirecting to %(app)s",
            authentication="require_authenticated",
        )

    def ensure_default_invalidation(self) -> _Resource:
        return self.ensure(
            DEFAULT_INVALIDATION_FLOW,
            designation="invalidation",
            name="Logged out of application",
            title="You've logged out of %(app)s.",
            authentication="none",
        )

    @overload
    def get_default_authorization_pk(self, throw: Literal[True]) -> int: ...
    @overload
    def get_default_authorization_pk(self, throw: bool = False) -> int | None: ...
    def get_default_authorization_pk(self, throw: bool = False) -> int | None:
        flow = self._api.get(self.path, {"slug": DEFAULT_AUTHORIZATION_FLOW})
        if flow is None:
            if throw:
                raise Exception(f"Authorization flow {DEFAULT_AUTHORIZATION_FLOW!r} not found")
            return None
        return cast(int, flow["pk"])

    @overload
    def get_default_invalidation_pk(self, throw: Literal[True]) -> int: ...
    @overload
    def get_default_invalidation_pk(self, throw: bool = False) -> int | None: ...
    def get_default_invalidation_pk(self, throw: bool = False) -> int | None:
        flow = self._api.get(self.path, {"slug": DEFAULT_INVALIDATION_FLOW})
        if flow is None:
            if throw:
                raise Exception(f"Invalidation flow {DEFAULT_INVALIDATION_FLOW!r} not found")
            return None
        return cast(int, flow["pk"])


class _ProxyProviderManager(_Manager):
    path = "/providers/proxy/"

    def ensure(self, name: str, **fields: Unpack[ProxyProviderFields]) -> _Resource:
        data = self._api.get(self.path, {"name": name}) or self._api.create(self.path, {"name": name, **fields})
        return _Resource(data)


class _OAuth2ProviderManager(_Manager):
    path = "/providers/oauth2/"

    def ensure(self, name: str, **fields: Unpack[OAuth2ProviderFields]) -> _OAuth2Provider:
        data = self._api.get(self.path, {"name": name}) or self._api.create(self.path, {"name": name, **fields})
        return _OAuth2Provider(data)


class _ApplicationManager(_Manager):
    path = "/core/applications/"

    def ensure(self, slug: str, **fields: Unpack[ApplicationFields]) -> _Resource:
        data = self._api.get(self.path, {"slug": slug}) or self._api.create(self.path, {"slug": slug, **fields})
        return _Resource(data)


class _OutpostManager(_Manager):
    path = "/outposts/instances/"

    def attach_provider(self, provider_pk: int, name: str = EMBEDDED_OUTPOST) -> None:
        instance = self._api.get(self.path, {"name": name})
        if instance is None:
            raise Exception(f"Outpost {name!r} not found")
        providers = cast(list[int], list(instance.get("providers") or []))
        if provider_pk in providers:
            return
        providers.append(provider_pk)
        self._api.patch(f"{self.path}{instance['pk']}/", {"providers": providers})


class _CertificateManager(_Manager):
    path = "/crypto/certificatekeypairs/"

    @overload
    def get_default_signing_key_pk(self, throw: Literal[True]) -> int: ...
    @overload
    def get_default_signing_key_pk(self, throw: bool = False) -> int | None: ...
    def get_default_signing_key_pk(self, throw: bool = False) -> int | None:
        cert = self._api.get(self.path, {"name": DEFAULT_SIGNING_KEY})
        if cert is None:
            if throw:
                raise Exception(f"Signing key {DEFAULT_SIGNING_KEY!r} not found")
            return None
        return cast(int, cert["pk"])


class _ScopeManager(_Manager):
    path = "/propertymappings/provider/scope/"

    @overload
    def get_managed_pk(self, managed: str, throw: Literal[True]) -> int: ...
    @overload
    def get_managed_pk(self, managed: str, throw: bool = False) -> int | None: ...
    def get_managed_pk(self, managed: str, throw: bool = False) -> int | None:
        scope = self._api.get(self.path, {"managed": managed})
        if scope is None:
            if throw:
                raise Exception(f"Managed scope {managed!r} not found")
            return None
        return cast(int, scope["pk"])


class AuthentikAPI:
    def __init__(self, base_url: str, token: str):
        self._base_url = base_url.rstrip("/")
        self._token = token
        self._ssl_ctx = ssl.create_default_context()
        self._ssl_ctx.check_hostname = False
        self._ssl_ctx.verify_mode = ssl.CERT_NONE

        self.flows = _FlowManager(self)
        self.proxy_providers = _ProxyProviderManager(self)
        self.oauth2_providers = _OAuth2ProviderManager(self)
        self.applications = _ApplicationManager(self)
        self.outposts = _OutpostManager(self)
        self.certificates = _CertificateManager(self)
        self.scopes = _ScopeManager(self)

    @classmethod
    def from_envs(cls) -> Self:
        return cls(
            base_url=f"https://{envs.get('AUTHENTIK_HOSTNAME')}/api/v3",
            token=envs.get("AUTHENTIK_BOOTSTRAP_TOKEN"),
        )

    def wait_until_ready(self, timeout: int = 180) -> None:
        deadline = time.time() + timeout
        while time.time() < deadline:
            try:
                self._request("GET", "/admin/version/")
                return
            except urllib.error.URLError:
                time.sleep(2)
        raise Exception("Authentik API did not become ready in time")

    def get_list(self, path: str, filters: Filters | None = None) -> list[Response]:
        full_path = f"{path}?{urllib.parse.urlencode(filters)}" if filters else path
        response = self._request("GET", full_path)
        return cast(list[Response], response.get("results") or [])

    def get(self, path: str, filters: Filters) -> Response | None:
        results = self.get_list(path, filters)
        return results[0] if results else None

    def create(self, path: str, body: Body) -> Response:
        return self._request("POST", path, body)

    def patch(self, path: str, body: Body) -> Response:
        return self._request("PATCH", path, body)

    def _request(self, method: str, path: str, body: Body | None = None) -> Response:
        data = json.dumps(body).encode() if body is not None else None
        req = urllib.request.Request(
            f"{self._base_url}{path}",
            data=data,
            method=method,
            headers={
                "Authorization": f"Bearer {self._token}",
                "Content-Type": "application/json",
            },
        )
        with urllib.request.urlopen(req, context=self._ssl_ctx) as resp:
            payload = resp.read()
        return cast(Response, json.loads(payload)) if payload else {}
