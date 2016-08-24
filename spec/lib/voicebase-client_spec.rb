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
    #pp( resp )
    expect(resp.status).to eq 200
    expect(resp.media).to be_a(Array)
    resp.media.each do |m|
      STDERR.puts "/media has #{m.inspect}"
    end
  end

  if ENV['VB_TEST_UPLOAD_URL']
    it "should upload media from an url" do
      client = get_vb_client
      resp = client.upload media: ENV['VB_TEST_UPLOAD_URL']
      expect(resp.status).to eq 200
      expect(resp.mediaId).not_to be_empty
      STDERR.puts "upload saved with mediaId #{resp.mediaId}"
    end

    it "should upload media with premium" do
      client = get_vb_client
      conf = { configuration: { transcripts: { engine: "premium" } } }.to_json
      resp = client.upload media: ENV['VB_TEST_UPLOAD_URL'], configuration: conf
      expect(resp.status).to eq 200
      expect(resp.mediaId).not_to be_empty
      STDERR.puts "upload saved with mediaId #{resp.mediaId}"
      # TODO poll for finish?
    end
  end

  if ENV['VB_TEST_UPLOAD']

    it "should upload media" do
      client = get_vb_client
      resp = client.upload media: ENV['VB_TEST_UPLOAD']
      expect(resp.status).to eq 200
      expect(resp.mediaId).not_to be_empty
      STDERR.puts "upload saved with mediaId #{resp.mediaId}"
      # TODO poll for finish?
    end

    it "should upload media with premium" do
      client = get_vb_client
      conf = { configuration: { transcripts: { engine: "premium" } } }.to_json
      resp = client.upload media: ENV['VB_TEST_UPLOAD'], configuration: conf
      expect(resp.status).to eq 200
      expect(resp.mediaId).not_to be_empty
      STDERR.puts "upload saved with mediaId #{resp.mediaId}"
      # TODO poll for finish?
    end

    if ENV['VB_CALLBACK_URL']
      it "should upload media with callback" do
        client = get_vb_client
        conf = { 
          configuration: { 
            transcripts: { engine: "premium" },
            publish: { 
              callbacks: [{ 
                method: "POST", 
                include: ["transcripts", "topics", "metadata"], 
                url: ENV['VB_CALLBACK_URL']
              }]
            }
          } 
        }.to_json
        resp = client.upload media: ENV['VB_TEST_UPLOAD'], configuration: conf
        expect(resp.status).to eq 200
        expect(resp.mediaId).not_to be_empty
        STDERR.puts "upload saved with mediaId #{resp.mediaId} for callback #{ENV['VB_CALLBACK_URL']}"
      end
    end

  end

  if ENV['VB_TEST_MEDIA_ID']

    it "should fetch records with mediaId" do

      client = get_vb_client
      resp = client.get '/media/' + ENV['VB_TEST_MEDIA_ID'].dup
      expect(resp.status).to eq 200
      #pp resp
      expect(resp.media.mediaId).to eq ENV['VB_TEST_MEDIA_ID']
      expect(resp.media.status).not_to be_empty

    end

    it "should fetch transcripts with mediaId" do

      client = get_vb_client
      resp = client.get '/media/' + ENV['VB_TEST_MEDIA_ID'].dup + '/transcripts/latest'
      expect(resp.status).to eq 200
      #pp resp
      expect(resp.transcript).not_to be_empty

    end

    it "should fetch transcripts with mediaId via transcripts method" do
    
      client = get_vb_client
      resp = client.transcripts( ENV['VB_TEST_MEDIA_ID'].dup, format: 'plain' )
      expect(resp.status).to eq 200
      #pp resp
      expect(resp.body).to be_a(String)

    end

  end

end

