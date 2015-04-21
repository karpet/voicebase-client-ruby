require 'spec_helper'

describe VoiceBase::Client do
  it "should initialize sanely" do
    client = get_vb_client
    #pp client
  end

  it "should fetch offerings" do
    client = get_vb_client
    resp = client.getOfferings length: 10, language: client.language
    #puts pp( resp )
    expect(resp.requestStatus).to eq 'SUCCESS'
    expect(resp.offerings.size).to be > 0
  end

end

