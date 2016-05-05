# Logstash Plugin

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Documentation

- This plugin is for diving a message into multi fileds by the given pattern

- see run logstash with the plugin as below!

## Need Help?

Need help? Try #logstash on freenode IRC or the https://discuss.elastic.co/c/logstash discussion forum.

## Developing

### 1. Plugin Developement and Testing

#### Code
- To get started, you'll need JRuby with the Bundler gem installed.

- Create a new plugin or clone and existing from the GitHub [logstash-plugins](https://github.com/logstash-plugins) organization. We also provide [example plugins](https://github.com/logstash-plugins?query=example).

- Install dependencies
```sh
bundle install
```

#### Test

- Update your dependencies

```sh
bundle install
```

- Run tests

```sh
bundle exec rspec
```

### 2. Running your unpublished Plugin in Logstash

#### 2.1 Run in a local Logstash clone

- Edit Logstash `Gemfile` and add the local plugin path, for example:
```ruby
gem "logstash-filter-cutter", :path => "/your/local/logstash-filter-cutter"
```
- Install plugin
```sh
# Logstash 2.3 and higher
bin/logstash-plugin install --no-verify

# Prior to Logstash 2.3
bin/plugin install --no-verify

```
- Run Logstash with the plugin
```sh
bin/logstash -f cutter.conf
cutter.conf:
input {
  generator {
    count => 1
    message => '[2016-03-28 07:23:33.348] [WARN] [nioEventLoopGroup-3-23] [com.cutter.handler.TestClass] >>> [Illegal request -  miss parameter] json={"a":"aaa","b":"bbb"} msg=Miss required parameter "mid" in request'
 }
}

filter {

    cutter {
      field => "message"
      pattern => ["[]","[]","[]","[]","[]","json=?","msg="]
      target => ["msgTimestamp", "logLevel", "threadName", "logger", "eventName", "jsoMsg"]
    }
}
#pattern is an array, if element of array is brackets or any other two bytes length's delimiter,then target has one corrrespond to it
#if element is a keyword or message head, then two such element is a couple, which has one target element corresponded to it
#"?" means the pattern element is optional, and "?" can be used in a keyword or message head 
output {
  stdout { codec => "rubydebug" }
}

results :
{
        "sequence" => 0,
    "msgTimestamp" => "2016-03-28 07:23:33.348",
          "jsoMsg" => "{\"a\":\"aaa\",\"b\":\"bbb\"}",
      "@timestamp" => 2016-04-29T07:25:11.432Z,
        "logLevel" => "WARN",
          "logger" => "com.cutter.handler.TestClass",
        "@version" => "1",
            "host" => "MacBook-Pro.local",
       "eventName" => "Illegal request -  miss parameter",
         "message" => "[2016-03-28 07:23:33.348] [WARN] [nioEventLoopGroup-3-23] [com.cutter.handler.TestClass] >>> [Illegal request -  miss parameter] json={"a":"aaa","b":"bbb"} msg=Miss required parameter "mid" in request",
      "threadName" => "nioEventLoopGroup-3-23"
}
```
At this point any modifications to the plugin code will be applied to this local Logstash setup. After modifying the plugin, simply rerun Logstash.

#### 2.2 Run in an installed Logstash

You can use the same **2.1** method to run your plugin in an installed Logstash by editing its `Gemfile` and pointing the `:path` to your local plugin development directory or you can build the gem and install it using:

- Build your plugin gem
```sh
gem build logstash-filter-cutter.gemspec
```
- Install the plugin from the Logstash home
```sh
# Logstash 2.3 and higher
bin/logstash-plugin install --no-verify

# Prior to Logstash 2.3
bin/plugin install --no-verify

```
- Start Logstash and proceed to test the plugin

## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members  saying "send patches or die" - you will not see that here.

It is more important to the community that you are able to contribute.

For more information about contributing, see the [CONTRIBUTING](https://github.com/elastic/logstash/blob/master/CONTRIBUTING.md) file.
