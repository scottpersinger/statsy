require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  def setup
    Domain.collection.insert(:domain => "foobar")
  end

  test "basic operations" do
    Domain.destroy_all
    assert_equal 0, Domain.count

    assert_nil Domain.find_one(:domain => "google.com")

    d = Domain.lookup_by_page("http://google.com/watch/393493?h=help")
    assert_not_nil d
    assert_not_nil d.id
    assert_equal "google.com", d.domain

    d2 = Domain.lookup_by_page("https://www.retouchme.net")
    assert_equal "retouchme.net", d2.domain

    assert d2.same_domain?("http://www.retouchme.net/page5?n=mike")

    d2.domain = "yahoo.com"
    d2.save

    d3 = Domain.find(d2.id)
    assert_equal "yahoo.com", d3.domain
  end

  test "page operations" do
    d = Domain.create(:domain => "retouchme.net")

    d.add_page("/")
    d.add_page("/products")
    d.add_page("/purchase")

    assert_equal 3, d.pages.size
    assert_equal 3, Domain.find(d.id).pages.size
    assert_instance_of Page, Domain.find(d.id).pages[0]

    d2 = Domain.create(:domain => "yahoo.com")
    d2.lookup_page("/")
    d2.lookup_page("")

    assert_equal 1, d2.pages.size
    
    products = d2.lookup_page("/products")
    assert_equal 2, d2.pages.size

    # Page matching tests
    assert_equal products, d2.lookup_page("/products?v=help&a=arg2")
    details = d2.lookup_page("/products/details#anchor?f=foo")
    assert_not_equal details, products

    assert_equal details, d2.lookup_page("/products/details?u=foo")
  end
end
