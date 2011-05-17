require "spec_helper"
require "httpi/adapter/curb"
require "httpi/request"

# curb does not run on jruby
unless RUBY_PLATFORM =~ /java/

  describe HTTPI::Adapter::Curb do
    before do
      HTTPI.adapter = :curb
    end

    let(:adapter) { HTTPI::Adapter::Curb.new }
    let(:curb) { Curl::Easy.any_instance }

    describe "#get" do
      before do
        curb.should_receive(:http_get)
        curb.should_receive(:response_code).and_return(200)
        curb.should_receive(:header_str).and_return("Accept-encoding: utf-8")
        curb.should_receive(:body_str).and_return(Fixture.xml)
      end

      it "returns a valid HTTPI::Response" do
        adapter.get(basic_request).should match_response(:body => Fixture.xml)
      end
    end

    describe "#post" do
      before do
        curb.should_receive(:http_post)
        curb.should_receive(:response_code).and_return(200)
        curb.should_receive(:header_str).and_return("Accept-encoding: utf-8")
        curb.should_receive(:body_str).and_return(Fixture.xml)
      end

      it "returns a valid HTTPI::Response" do
        adapter.post(basic_request).should match_response(:body => Fixture.xml)
      end
    end

    describe "#post" do
      it "sends the body in the request" do
        curb.should_receive(:http_post).with('xml=hi&name=123')
        adapter.post(basic_request { |request| request.body = 'xml=hi&name=123' } )
      end
    end

    describe "#head" do
      before do
        curb.should_receive(:http_head)
        curb.should_receive(:response_code).and_return(200)
        curb.should_receive(:header_str).and_return("Accept-encoding: utf-8")
        curb.should_receive(:body_str).and_return(Fixture.xml)
      end

      it "returns a valid HTTPI::Response" do
        adapter.head(basic_request).should match_response(:body => Fixture.xml)
      end
    end

    describe "#put" do
      before do
        curb.should_receive(:http_put)
        curb.should_receive(:response_code).and_return(200)
        curb.should_receive(:header_str).and_return("Accept-encoding: utf-8")
        curb.should_receive(:body_str).and_return(Fixture.xml)
      end

      it "returns a valid HTTPI::Response" do
        adapter.put(basic_request).should match_response(:body => Fixture.xml)
      end
    end

    describe "#put" do
      it "sends the body in the request" do
        curb.should_receive(:http_put).with('xml=hi&name=123')
        adapter.put(basic_request { |request| request.body = 'xml=hi&name=123' } )
      end
    end

    describe "#delete" do
      before do
        curb.should_receive(:http_delete)
        curb.should_receive(:response_code).and_return(200)
        curb.should_receive(:header_str).and_return("Accept-encoding: utf-8")
        curb.should_receive(:body_str).and_return("")
      end

      it "returns a valid HTTPI::Response" do
        adapter.delete(basic_request).should match_response(:body => "")
      end
    end

    describe "settings:" do
      before { curb.stub(:http_get) }

      describe "url" do
        it "always sets the request url" do
          curb.should_receive(:url=).with(basic_request.url.to_s)
          adapter.get(basic_request)
        end
      end

      describe "proxy_url" do
        it "is not set unless it's specified" do
          curb.should_receive(:proxy_url=).never
          adapter.get(basic_request)
        end

        it "is set if specified" do
          request = basic_request { |request| request.proxy = "http://proxy.example.com" }

          curb.should_receive(:proxy_url=).with(request.proxy.to_s)
          adapter.get(request)
        end
      end

      describe "timeout" do
        it "is not set unless it's specified" do
          curb.should_receive(:timeout=).never
          adapter.get(basic_request)
        end

        it "is set if specified" do
          request = basic_request { |request| request.read_timeout = 30 }

          curb.should_receive(:timeout=).with(30)
          adapter.get(request)
        end
      end

      describe "connect_timeout" do
        it "is not set unless it's specified" do
          curb.should_receive(:connect_timeout=).never
          adapter.get(basic_request)
        end

        it "is set if specified" do
          request = basic_request { |request| request.open_timeout = 30 }

          curb.should_receive(:connect_timeout=).with(30)
          adapter.get(request)
        end
      end

      describe "headers" do
        it "is always set" do
          curb.should_receive(:headers=).with({})
          adapter.get(basic_request)
        end
      end

      describe "verbose" do
        it "is always set to false" do
          curb.should_receive(:verbose=).with(false)
          adapter.get(basic_request)
        end
      end

      describe "http_auth_types" do
        it "is set to :basic for HTTP basic auth" do
          request = basic_request { |request| request.auth.basic "username", "password" }

          curb.should_receive(:http_auth_types=).with(:basic)
          adapter.get(request)
        end

        it "is set to :digest for HTTP digest auth" do
          request = basic_request { |request| request.auth.digest "username", "password" }

          curb.should_receive(:http_auth_types=).with(:digest)
          adapter.get(request)
        end
      end

      describe "username and password" do
        it "is set for HTTP basic auth" do
          request = basic_request { |request| request.auth.basic "username", "password" }

          curb.should_receive(:username=).with("username")
          curb.should_receive(:password=).with("password")
          adapter.get(request)
        end

        it "is set for HTTP digest auth" do
          request = basic_request { |request| request.auth.digest "username", "password" }

          curb.should_receive(:username=).with("username")
          curb.should_receive(:password=).with("password")
          adapter.get(request)
        end
      end

      context "(for SSL client auth)" do
        let(:ssl_auth_request) do
          basic_request do |request|
            request.auth.ssl.cert_key_file = "spec/fixtures/client_key.pem"
            request.auth.ssl.cert_file = "spec/fixtures/client_cert.pem"
          end
        end

        it "cert_key, cert and ssl_verify_peer should be set" do
          curb.should_receive(:cert_key=).with(ssl_auth_request.auth.ssl.cert_key_file)
          curb.should_receive(:cert=).with(ssl_auth_request.auth.ssl.cert_file)
          curb.should_receive(:ssl_verify_peer=).with(true)
          curb.should_receive(:certtype=).with(ssl_auth_request.auth.ssl.cert_type.to_s.upcase)

          adapter.get(ssl_auth_request)
        end

        it "sets the cert_type to DER if specified" do
          ssl_auth_request.auth.ssl.cert_type = :der
          curb.should_receive(:certtype=).with(:der.to_s.upcase)

          adapter.get(ssl_auth_request)
        end

        it "sets the cacert if specified" do
          ssl_auth_request.auth.ssl.ca_cert_file = "spec/fixtures/client_cert.pem"
          curb.should_receive(:cacert=).with(ssl_auth_request.auth.ssl.ca_cert_file)

          adapter.get(ssl_auth_request)
        end
      end
    end

    def basic_request
      request = HTTPI::Request.new :url => "http://example.com"
      yield request if block_given?
      request
    end

  end
end
