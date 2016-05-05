# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"


class LogStash::Filters::Cutter < LogStash::Filters::Base

 
  config_name "cutter"

  # The field whose value is to be cut.
  config :field, :validate => :string, :default => "message"

  config :pattern, :validate => :array

  config :target, :validate => :array


  public
  def register
    # Add instance variables
  end # def register

  public
  def filter(event)

    original_value = event[@field]
    if !original_value.nil?
      i, j, offset = 0, 0, 0
      while i < @pattern.length and j < @target.length
        if @pattern[i].length == 2
          event[@target[j]], offset = match_bracket(original_value, @pattern[i], offset)
          i += 1
        else
          event[@target[j]], offset = match(original_value, @pattern[i], @pattern[i + 1], offset)
          i += 2
        end
        j += 1
      end
    else
      @logger.error("No such a filed #{@field}")
    end
    filter_matched(event)
  end # def filter


  private
  def match(str, head, tail, offset)
    s, e = 0, 0
    if head[-1] == "?" and (head[-2] == "=" or head[-2] == ":")
      head = head[0..-2]
      index = str.index(head, offset)
      if index.nil?
        return nil, offset
      end
    elsif head[-1] == "=" or head[-1] == ":"
      index = str.index(head, offset)
      if index.nil?
        @logger.error("can't find such a head(%s) in %s" % [head, str])
        return nil, offset
      end
    end
    offset = index + head.length
    s = offset
    if !tail.nil?
      if tail[-1] == "?"
        tail = tail[0..-2]
      end
      index = str.index(tail, offset)
      if index.nil?
        e = -1
      end
      offset = index
      e = offset - 2   # message: ... json={...} msg=
    else
      e = -1
    end
    return str[s..e], offset
  end # def match

  private
  def match_bracket(str, bracket, offset)
    s, e = 0, 0
    index = str.index(bracket[0], offset)
    if index.nil?
      @logger.error("can't match such a bracket(%s) in %s" % [bracket, str])
      return nil, offset
    end
    offset = index + 1
    s = offset
    index = str.index(bracket[1], offset)
    if index.nil?
      @logger.error("can't match such a bracket(%s) in %s" % [bracket, str])
      return nil, offset
    end
    offset = index + 1   # message: ...[some words] index ...
    e = offset - 2

    return str[s..e], offset

  end # def match_bracket

end # class LogStash::Filters::Cutter
