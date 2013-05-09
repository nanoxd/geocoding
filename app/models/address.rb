class Address < ActiveRecord::Base
  require 'open-uri'
  require 'cgi'
  require 'hpricot'

  attr_accessible :city, :country, :error_code, :latitude, :longitude, :state, :street, :streetno, :suburb, :zipcode
  before_save :geocode_with_cache

  def minimal_clean_address
    [streetno, street, city, zip_code, country].to_a.compact.join(",")
  end

  def api_url
    "http://maps.googleapis.com/maps/api/geocode/xml?sensor=false"
  end

  def api_query
    "#{api_url}&amp;address=#{minimal_clean_address}"
  end

  def geocode
    open(api_query) do |file|
      @body = file.read
      doc = Hpricot(@body)
      parse_response(doc)
    end
  end

  def parse_response(doc)
    self.error_code = (doc/:status).first.inner_html
    if error_code.eql? "OK"
      set_coordinates(doc)
      complete_address(doc)
    end
  end

  def set_coodinates(doc)
    self.latitude = (doc/:geometry/:location/:lat).first.inner_html
    self.longitude = (doc/:geometry/:location/:lng).first.inner_html
  end

  def complete_address(doc)
    (doc/:result/:address_component).each do |ac|
      if (ac/:type).first.inner_html == "sublocality"
        self.suburb = (ac/:long_name).first.inner_html
      end

      if (ac/:type).first.inner_html == "administrative_area_level_3"
        self.county = (ac/:long_name).first.inner_html
      end

      if (ac/:type).first.inner_html == "administrative_area_level_1"
        self.state = (ac/:long_name).first.inner_html
      end
    end
  end

  def geocode_with_cache
    c_address = address_lookup
    if c_address
      copy_cached_date(c_address)
    else
      geocode
    end
  end

  def address_lookup
    Address.where(cache_query).last
  end

  def cache_query
    ["streetno = ? AND street = ? AND city = ? and zipcode = ?", streetno, street, city, zipcode]
  end

  def copy_cached_data(ca)
    self.latitude = ca.latitude
    self.longitude = ca.longitude
    self.suburb = ca.suburb
    self.county = ca.county
    self.state = ca.state
  end


end
