class Address < ActiveRecord::Base
  require 'open-uri'
  require 'cgi'
  require 'hpricot'

  attr_accessible :city, :country, :error_code, :latitude, :longitude, :state, :street, :streetno, :suburb, :zipcode

  def minimal_clean_address
    [streetno, street, city, zip_code, country].to_a.compact.join(",")
  end

  def api_url
    "http://maps.googleapis.com/maps/api/geocode/xml?sensor=false"
  end

  def api_query
    "#{api_url}&amp;address=#{minimal_clean_address}
  end
end
