import logging
import os

try:
    from azure.core.exceptions import ClientAuthenticationError, HttpResponseError
    from azure.identity import AzureCliCredential
    from azure.mgmt.resource import ResourceManagementClient
    from azure.mgmt.resource.subscriptions import SubscriptionClient
except ImportError as exc:
    raise ImportError(
        "Required Azure SDK packages are missing. Install them with: "
        "pip install azure-core azure-identity azure-mgmt-resource"
    ) from exc


logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
logger = logging.getLogger(__name__)


def get_subscription_id() -> str:
    subscription_id = os.environ.get("AZURE_SUBSCRIPTION_ID")
    if not subscription_id:
        raise RuntimeError("AZURE_SUBSCRIPTION_ID is not set")
    return subscription_id


def main() -> None:
    subscription_id = get_subscription_id()

    # azure/login authenticates Azure CLI with OIDC; this credential reuses that session.
    credential = AzureCliCredential()
    subscription_client = SubscriptionClient(credential)
    resource_client = ResourceManagementClient(credential, subscription_id)

    try:
        subscription = subscription_client.subscriptions.get(subscription_id)
        resource_groups = list(resource_client.resource_groups.list())
    except ClientAuthenticationError:
        logger.exception("OIDC authentication failed")
        raise
    except HttpResponseError:
        logger.exception(
            "Azure authentication succeeded, but the identity lacks required RBAC access"
        )
        raise
    finally:
        subscription_client.close()
        resource_client.close()

    logger.info("OIDC authentication succeeded")
    logger.info("Subscription: %s", subscription.display_name)
    logger.info("Visible resource groups: %d", len(resource_groups))


if __name__ == "__main__":
    main()
