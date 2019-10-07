# ak

Lightweight library for "hot code" reloading.  

Check the [demo](https://github.com/BeRMaNyA/ak/tree/master/cuba-app)

## Installation

Install the latest version from rubygems.

```
$ gem install ak
```

### Setup

Require the ak gem and set the environment and root directory.  
The reloader will not work if the environment is not development.

```ruby
require 'ak'

Ak.env = 'development'
Ak.root = File.expand_path('../', __FILE__)
```

### Usage

```ruby
Ak.require 'path/to/file'
Ak.require_relative 'file'
Ak.require_folders 'lib', 'app'
```

These methods will require the file and will automatically load the constant.  

You can still use the ruby syntax for requiring the files and also reload the constants, i.e:

```ruby
require_relative 'file'
require_relative 'lib/test'
require_relative 'app/test'

Ak.reload 'file'
Ak.reload_folders 'lib', 'app'
```

If the class name doesn't match with the file name, you can do this:

```ruby
Ak.require 'test_file', const: :AnotherClassName
Ak.require 'test_file', const: 'Module::Class'
```

Listen for changes:

```ruby
Ak.start
```

### TODO

- [ ] Finish Cuba App
- [ ] Tests
- [ ] Support callbacks
- [ ] Improves constant finder
