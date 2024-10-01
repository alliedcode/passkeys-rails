### 0.3.3 (Next)

- Your contribution here.

### 0.3.2 (2024/10/01)

- Changed from unsigned cookies to short lived signed cookies
- Added RELEASING.md

### 0.3.1 (2023/11/30)

- Fixed a bug in reading session/cookie variables
- Added webauthn configuration parameters to this gem's configuration
- Moved configuration to its own class
- Added more info to the README

### 0.3.0 (2023/08/01)

- Added debug_register endpoint.
- Fixed authenticatable_params for register enpoint.
- Added notifications to certain controller actions.
- Improved spec error helper.

### 0.2.1 (2023/07/29)

Added ability to pass either the auth token string or a request with one in the header to authenticate methods.

### 0.2.0 (2023/07/28)

- Added passkeys/debug_login functionality.

### 0.1.7 (2023/07/26)

- Added IntegrationHelpers to support client testing.
- Updated methods for interfacing with Rails client app.
- Changed route path added by the generator.

### 0.1.6 (2023/07/26)

- Added default_class and class_whitelist config parameters.

### 0.1.5 (2023/07/24)

- Updated validation to ensure the agent has completed registration to be considered valid.

### 0.1.4 (2023/07/23)

- Changed namespace from Passkeys::Rails to PasskeysRails

### 0.1.3 (2023/07/23)

- More restructuring and fixed issue where autoloading failed
  during client app initialization.

### 0.1.2 (2023/07/23)

- Restructured lib directory.

- Fixed naming convention for gem/gemspec.

- Fixed exception handling.

### 0.1.1 (2023/07/23)

- Fixed dependency

### 0.1.0 (2023/07/23)

- Initial release - looking for feedback
