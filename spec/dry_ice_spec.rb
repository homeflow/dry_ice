require 'spec_helper.rb'
require 'active_support'


describe HTTParty::DryIce do

  context "when being set up" do

    it "accepts a cache instance that quacks like a ActiveSupport cache" do

      expect do
          class MockApi
            cache(Object.new)
          end
      end.to raise_error 

      expect do
          class MockApi
            cache(ActiveSupport::Cache::NullStore.new)
          end
      end.not_to raise_error

    end
  end


  context "when performing a request" do


    it "should not use read to check existance" do

      class MockApi
        cache(ActiveSupport::Cache::NullStore.new)
      end

       ActiveSupport::Cache::NullStore.any_instance.should_receive(:read)

       stub_request(:get, "http://example.com/").to_return(:status => 200, :body => "test", :headers => {})     
      
       MockApi.get('/')

    end
 
     
    it "does not cache requests without a cache header" do

      class MockApi
        cache(nil)
      end

      stub_request(:get, "http://example.com/").to_return(:status => 200, :body => "test", :headers => {:cache_control => 'max-age=10'})     
      
      response = MockApi.get('/')

      expect(MockApi.cache_response?(response)).to be 10
      
    end

    

  end
end


describe HTTParty::DryIce::IceCache do


  it "should be able to marshel and store a HTTParty request" do
    stub_request(:get, "http://example.com/").to_return(:status => 200, :body => "hello world", :headers => {:cache_control => 'max-age=0'})     
    response = MockApi.get('/')
    cache = HTTParty::DryIce::IceCache.new(ActiveSupport::Cache::NullStore.new)

    serialised = cache.serialize_response(response)
    res = cache.build_response(serialised)

    res.body.should == response.body
    res.headers.should == response.headers

  end

end