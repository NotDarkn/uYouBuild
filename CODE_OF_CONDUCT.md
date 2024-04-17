# Code of Conduct for This Repostory
If I verify a reported Code of Conduct violation, my policy is:

- Contributors are allowed to make patches only to the main branch, unless an additional branch is involved. This policy applies to the implementation of custom features/options, updated features/options, and grammar errors.

- uYouEnhanced does not support Localization pull requests. While it may seem like a sudden change, maintaining localization becomes challenging when the branch needs to be reset due in order to push to the latest changes from qnblackcat/uYouPlus repository. Therefore, it is difficult to preserve any localization changes that were added on uYouEnhanced since the fork/branch can get reset and takes too long to add them all back.

- The use of the name `uYouPlusExtra` is prohibited. The correct and updated name for this repository is `uYouEnhanced`.
  - if there is a tweak named or have the description of the word `uYouPlusExtra` then please do check it out before you interact with it or use it.

- Users who fork this repository, utilize it in actions, or build it from the repository on Git are prohibited from releasing .ipa files on their forked repositories. This restriction is in place to comply with the following https://enterprise.githubsupport.com/attachments/token/1u4kyYJnjA8HZTPMXOGBhRk4Q/?, also, preventing any potential legal issues. If a user violates this rule by including an .ipa file in their GitHub release publicly, appropriate actions will be taken from either the tweak developer or Google since .ipa's aren't allowed, they have the rights to do that. I apologize but it's the only way keep the repo from getting taken down.
**Simpiflied Version:** when building the ipa from your forked repository of uYouEnhanced, please do not upload and publish any .ipa files or I will have to do a request to take it down.

<details>
  <summary>Exclusive Rule for the original uYouPlus devs ⬇️</summary>
- Devs **qnblackcat** and **PoomSmart** are not allowed to use any new or changed code from the uYouEnhanced fork (excludes **AppIconOptionsController.m** & **AppIconOptionsController.h**) unless it is absolutely necessary. Breaking this rule may result in consequences like access revocation. it is strictly forbidden to publicly share or showcase the content of this policy on any social media platforms. This rule is in place to protect any of the rejected features in uYouEnhanced, refering to (LowContrastMode, Hide Shadow Overlay Button, YTHoldForSpeed & etc.)
To prevent conflicts and misunderstandings related to donations, all users should use code from the uYouEnhanced fork responsibly and honor the permissions and restrictions provided by the project administrators and tweak developers. Failure to do so may result in access revocation.
</details>

## Supported Versions

The following versions of the uYouEnhanced Tweak are currently supported with security and feature updates.

| Developer(s) | Version | LTS Support | YT Version Supported | App Stability | uYou Functionality |
|  ----------- | ------- | ----------- | -------------------- | ------------- | ------------------ |
| MiRO92(uYou) & arichornlover(uYouEnhanced) | [latest](https://github.com/arichornlover/uYouEnhanced/releases/latest) | ✅ | ✅ | Stable | Fully functional |
| MiRO92(uYou) & bhackel(uYouEnhanced-LTS) | [19.06.2-3.0.3 LTS](https://github.com/bhackel/uYouEnhanced/releases/tag/v19.06.2-3.0.3-(185)) | ✅ | ✅ | Stable, only provides version 19.06.2 of YouTube and uYou 3.0.3 | Crashes the app if the video is in fullscreen on an iPad, which would only happen if you installed the .ipa using a different sideloading/jailbreak tool. |
| MiRO92(uYou) & arichornlover(uYouEnhanced-LTS)| [16.42.3-2.1 LTS](https://github.com/arichornlover/uYouEnhanced/tree/main-16.42.3LTS) | Discontinued | ❌ | iOS 16+ compatibility issues, some features may not work properly. App will not work anymore, affecting versions v16.05.7-v17.32.2 as well. 💔 | uYou Video/Audio Downloading is offline (except uYouLocal). |
