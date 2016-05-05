# encoding: utf-8
require 'spec_helper'
require "logstash/filters/cutter"

describe LogStash::Filters::Cutter do
  describe "cut field by the given pattern" do
    let(:config) do <<-CONFIG
      filter {
        cutter {
          field => "message"
          pattern => ["[]","[]","[]","[]","[]","json=?","msg="]
          target => ["msgTimestamp","logLevel","threadName","logger","eventName","jsonMsg"]
        }
      }
    CONFIG
    end

    sample("message" => '[2016-03-28 07:23:33.348] [WARN] [nioEventLoopGroup-3-23] [com.cxl.mobile.probe.handler.ProbeV1Handler] >>> [Illegal request -  miss parameter] json={"a":"aaa","b":"bbb"} msg=Miss required parameter "mid" in request') do
      expect(subject).to include("msgTimestamp")
      expect(subject['msgTimestamp']).to eq('2016-03-28 07:23:33.348')
      expect(subject).to include("jsonMsg")
      expect(subject['jsonMsg']).to eq('{"a":"aaa","b":"bbb"}')
    end
  end
end
