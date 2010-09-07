require 'test_helper'

class VisitsTest < ActionDispatch::IntegrationTest
  fixtures :all

  # Replace this with your real tests.
  test "a visit" do
    visitor_id = 100
    referrer = "http://google.com"

    page = "http://retouchme.net/"
    get "/record/pageview?v=#{visitor_id}&p=#{page}&r=#{referrer}"
  end
end
