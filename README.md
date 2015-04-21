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

resp = client.getOfferings length: 10, language: client.language

```

