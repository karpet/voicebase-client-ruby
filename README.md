VoiceBase.com Ruby Client SDK
=====================================

http://www.voicebase.com/developers/

Example:

```ruby
require 'voicebase'

# create a client
client = VoiceBase::Client.new(
  :id     => 'apikeystring',
  :secret => 'vb_sekrit_password',
)

resp = client.get '/media'

```

The master branch implements version 2 of the VoiceBase API.

See the **v1** branch for the API version 1.

