require 'spec_helper'

describe VoiceBase::Client do
  it "should initialize sanely" do
    client = get_vb_client
    #pp client
    expect(client).to be_a(VoiceBase::Client)
  end

  it "should fetch /media" do
    client = get_vb_client
    resp = client.get('/media')
    #puts pp( resp )
    expect(resp.status).to eq 200
    expect(resp.media).to be_a(Array)
  end

end

