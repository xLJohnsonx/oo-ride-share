require_relative 'spec_helper'
require 'pry'

describe "Driver class" do

  describe "Driver instantiation" do
    before do
      @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV",
                                      vehicle_id: "1C9EVBRM0YBC564DZ",
                                      phone: '111-111-1111',
                                      status: :AVAILABLE)
    end

    it "is an instance of Driver" do
      expect(@driver).must_be_kind_of RideShare::Driver
    end

    it "throws an argument error with a bad ID value" do
      expect{ RideShare::Driver.new(id: 0, name: "George", vehicle_id: "33133313331333133")}.must_raise ArgumentError
    end

    it "throws an argument error with a bad VIN value" do
      expect{ RideShare::Driver.new(id: 100, name: "George", vehicle_id: "")}.must_raise ArgumentError
      expect{ RideShare::Driver.new(id: 100, name: "George", vehicle_id: "33133313331333133extranums")}.must_raise ArgumentError
    end

    it "sets driven trips to an empty array if not provided" do
      expect(@driver.driven_trips).must_be_kind_of Array
      expect(@driver.driven_trips.length).must_equal 0
    end

    it "is set up for specific attributes and data types" do
      [:id, :name, :vehicle_id, :status, :driven_trips].each do |prop|
        expect(@driver).must_respond_to prop
      end

      expect(@driver.id).must_be_kind_of Integer
      expect(@driver.name).must_be_kind_of String
      expect(@driver.vehicle_id).must_be_kind_of String
      expect(@driver.status).must_be_kind_of Symbol
    end
  end

  describe "add_driven_trip method" do
    before do
      pass = RideShare::User.new(id: 1, name: "Ada", phone: "412-432-7640")
      @driver = RideShare::Driver.new(id: 3, name: "Lovelace", vehicle_id: "12345678912345678", status: "UNAVAILABLE")
      @trip = RideShare::Trip.new(id: 8, driver: @driver, passenger: pass, start_time: Time.parse("2016-08-08"),
                                  end_time: Time.parse("2018-08-09"), rating: 5)
    end

    it "throws an argument error if trip is not provided" do
      expect{ @driver.add_driven_trip(1) }.must_raise ArgumentError

    end

    it "increases the trip count by one" do
      previous = @driver.driven_trips.length
      @driver.add_driven_trip(@trip)
      expect(@driver.driven_trips.length).must_equal previous + 1
    end
  end

  describe "average_rating method" do
    before do
      @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV",
                                      vehicle_id: "1C9EVBRM0YBC564DZ",
                                    status: "AVAILABLE")
      trip1 = RideShare::Trip.new(id: 8,
                                 driver: @driver, passenger: nil,
                                 start_time: Time.parse("2016-08-08"),
                                 end_time: Time.parse("2016-08-08"),
                                 cost: 14.50,
                                 rating: 5)

      @driver.add_driven_trip(trip1)
    end
    let (:trip2) {
      RideShare::Trip.new(id: 8, driver: @driver, passenger: nil,
                                  start_time: Time.parse("2016-08-08"),
                                  end_time: Time.parse("2016-08-09"),
                                  rating: 1,
                                  cost: 10)
    }

    let (:trip3) {
      RideShare::Trip.new(id: 8,
                                driver: @driver, passenger: nil,
                                start_time: Time.parse("2016-08-08"),
                                end_time: nil,
                                cost: nil,
                                rating: nil)
    }

    it "returns a float" do
      expect(@driver.average_rating).must_be_kind_of Float
    end

    it "returns a float within range of 1.0 to 5.0" do
      average = @driver.average_rating
      expect(average).must_be :>=, 1.0
      expect(average).must_be :<=, 5.0
    end

    it "returns zero if no driven trips" do
      driver = RideShare::Driver.new(id: 54,
                                    name: "Rogers Bartell IV",
                                     vehicle_id: "1C9EVBRM0YBC564DZ",
                                     status: "AVAILABLE")
      expect(driver.average_rating).must_equal 0
    end

    it "correctly calculates the average rating" do

      @driver.add_driven_trip(trip2)

      expect(@driver.average_rating).must_be_close_to (5.0 + 1.0) / 2.0, 0.01
    end

    it "calculates average rating correctly, leaving out trips in progress" do
      @driver.add_driven_trip(trip2)
      @driver.add_driven_trip(trip3)

      expect(@driver.average_rating).must_be_close_to (5.0 + 1.0) / 2.0, 0.01
    end


  end

  describe "total_revenue" do
    before do
      @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV",
                                      vehicle_id: "1C9EVBRM0YBC564DZ",
                                    status: "AVAILABLE")
      trip1 = RideShare::Trip.new(id: 8,
                                 driver: @driver, passenger: nil,
                                 start_time: Time.parse("2016-08-08"),
                                 end_time: Time.parse("2016-08-08"),
                                 cost: 14.50,
                                 rating: 5)
      trip2 = RideShare::Trip.new(id: 8, driver: @driver, passenger: nil,
                                 start_time: Time.parse("2016-08-08"),
                                 end_time: Time.parse("2016-08-09"),
                                 rating: 1,
                                 cost: 10)
      @driver.add_driven_trip(trip2)
      @driver.add_driven_trip(trip1)

    end

    it "correctly calculates total revenue" do
      #total cost = 24.50
      expect (@driver.total_revenue).must_be_close_to ((14.50 - 1.65) + (10 - 1.65)) * 0.80
    end
  end

  describe "net_expenditures" do
    before do
      trip3 = RideShare::Trip.new(id: 8,
                                 driver: nil,
                                 passenger: 54,
                                 start_time: Time.parse("2018-07-30 22:23:55 -0700"),
                                 end_time: Time.parse("2018-07-30 22:30:55 -0700"),
                                 cost: 15,
                                 rating: 5)
      trip4 = RideShare::Trip.new(id: 8,
                                 driver: nil,
                                 passenger: 54,
                                 start_time: Time.parse("2018-08-19 20:08:00 -0700"),
                                 end_time: Time.parse("2018-08-19 20:20:14 -0700"),
                                 cost: 35,
                                 rating: 5)

      @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV",
                                      vehicle_id: "1C9EVBRM0YBC564DZ",
                                    status: "AVAILABLE",
                                  trips: [trip3, trip4])
      trip1 = RideShare::Trip.new(id: 54,
                                 driver: @driver, passenger: nil,
                                 start_time: Time.parse("2016-08-08 22:30:55 -0700"),
                                 end_time: Time.parse("2016-08-08 22:35:55 -0700"),
                                 cost: 14.50,
                                 rating: 5)
      trip2 = RideShare::Trip.new(id: 8, driver: @driver, passenger: nil,
                                 start_time: Time.parse("2016-08-08 20:08:00 -0700"),
                                 end_time: Time.parse("2016-08-09 20:20:14 -0700"),
                                 rating: 1,
                                 cost: 10)
      @driver.add_driven_trip(trip2)
      @driver.add_driven_trip(trip1)
      # binding.pry
    end
    it "correctly calculated net expenditure" do
      total_money_earned = ((14.50 - 1.65) + (10 - 1.65)) * 0.80
      total_money_spent = 15 + 35

      expect(@driver.net_expenditures).must_be_close_to (total_money_spent - total_money_earned)
    end
  end
end
