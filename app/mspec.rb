require 'mspec/matchers'
require 'mspec/expectations'
require 'mspec/mocks'
require 'mspec/runner'
require 'mspec/guards'
require 'mspec/helpers'

# If the implementation on which the specs are run cannot
# load pp from the standard library, add a pp.rb file that
# defines the #pretty_inspect method on Object or Kernel.
require 'mspec/pp'

require 'mspec/utils/script'
require 'mspec/version'

# Rhodesのclass_evalは、ブロックをパラメータにとるメソッドしかサポートされていないので、Mockのメソッドを再定義
class Object
  unless method_defined? :metaclass
    def metaclass
      class << self; self; end
    end
  end
end
module Mock
  def self.install_method(obj, sym, type=nil)
    meta = obj.metaclass

    key = replaced_key obj, sym
    sym = sym.to_sym

    if (sym == :respond_to? or mock_respond_to?(obj, sym)) and !replaced?(key.first)
      meta.__send__ :alias_method, key.first, sym
    end

    meta.class_eval do
      define_method(sym) do |*args, &block|
        Mock.verify_call self, sym, *args, &block
      end
    end

    proxy = MockProxy.new type

    if proxy.mock?
      MSpec.expectation
      MSpec.actions :expectation, MSpec.current.state
    end

    if proxy.stub?
      stubs[key].unshift proxy
    else
      mocks[key] << proxy
    end
    objects[key] = obj

    proxy
  end
end