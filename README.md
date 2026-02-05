# Slack Bot Setup Instructions

## App creation
Go to https://api.slack.com/apps and create an app

## Updating the scope
Under App Manifest paste this and replace `YOUR_APP_NAME` with your app name:

```
{
    "display_information": {
        "name": "YOUR_APP_NAME"
    },
    "features": {
        "bot_user": {
            "display_name": "YOUR_APP_NAME",
            "always_online": true
        }
    },
    "oauth_config": {
        "scopes": {
            "bot": [
                "chat:write.public",
                "chat:write",
                "channels:history",
                "channels:read",
                "channels:join",
                "groups:history",
                "app_mentions:read",
                "im:read",
                "im:write",
                "im:history",
                "users:read"
            ]
        }
    },
    "settings": {
        "interactivity": {
            "is_enabled": true
        },
        "org_deploy_enabled": false,
        "socket_mode_enabled": true,
        "token_rotation_enabled": false
    }
}
```

After modifying the manifest save the changes.

## Under OAuth & Permission get SLACK_BOT_TOKEN.
Go to Oauth&Permissions

Click Install to `YOUR_WORKSPACE`

## Set environment variables
You need 2 things:
1. The `SLACK_BOT_TOKEN`
  - Go to Oauth&Permissions and find  `Bot User OAuth Token`
  - Copy it and export it to the `SLACK_BOT_TOKEN` environment variable
2. The `SLACK_DM_ID`
  - Go to your Slack App and click on your profile picture in the lower left. Then select `Profile` and in the window that is opened click the three dots and select `Copy member ID`
  - Copy this to the `SLACK_DM_ID` environment variable - This will be used for testing.

# Codeplain rendering instructions

When `SLACK_BOT_TOKEN` and `SLACK_DM_ID` is set in the environement variables you can run the render:

```
codeplain slack_chat_app.plain
```

You should start getting messages to slack while rendering.