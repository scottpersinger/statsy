require 'test_helper'

class PageviewsTest < ActiveSupport::TestCase
  def setup
    Domain.destroy_all
    @d = Domain.create(:domain => "foobar")
    if Domain.database.collection_names.include?(@d.pageviews_collection_name)
      Domain.database.collection(@d.pageviews_collection_name).remove
      @d.visitors_collection.remove
    end
  end

  def dump(pageviews)
    puts((pageviews.is_a?(Pageviews) ? pageviews.collection : pageviews).find.to_a)
  end
  
  test "basic pageviews" do
    url1 = "http://#{@d.domain}/"
    url2 = "http://#{@d.domain}/producs"

    pageviews = Pageviews.new(@d)
    pageviews.record_page_view(:page => url1)
    pageviews.record_page_view(:page => url2)

    assert_equal 2, pageviews.collection.find.count

    5.times {pageviews.record_page_view(:page => url1)}
    
    assert_equal 2, pageviews.collection.find.count
    assert_equal 6, pageviews.count(url1)
    assert_equal 1, pageviews.count(url2)
    assert_equal 7, pageviews.count

  end

  test "pageview tracking" do
    urls = ["http://#{@d.domain}/", "http://#{@d.domain}/products", "http://#{@d.domain}/purchase"]

    visitor1 = "1"
    visitor2 = "2"

    pageviews = Pageviews.new(@d)
    pageviews.record_view(:page => urls[0], :visitor_id => visitor1, :referrer => "http://google.com")
    pageviews.record_view(:page => urls[1], :visitor_id => visitor1, :referrer => urls[0])
    pageviews.record_view(:page => urls[2], :visitor_id => visitor1, :referrer => urls[1])
    pageviews.record_view(:page => urls[1], :visitor_id => visitor1, :referrer => urls[2])
    pageviews.record_view(:page => urls[1], :visitor_id => visitor1, :referrer => urls[0])
    pageviews.record_view(:page => urls[1], :visitor_id => visitor2, :referrer => "http://yahoo.com")

    #dump(pageviews)
    
    assert_equal 6, pageviews.count
    assert_equal 4, pageviews.count(urls[1])

    dump(@d.visitors_collection)
  end

end
