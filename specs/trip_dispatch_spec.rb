require_relative 'spec_helper'

USER_TEST_FILE   = 'specs/test_data/users_test.csv'
TRIP_TEST_FILE   = 'specs/test_data/trips_test.csv'
DRIVER_TEST_FILE = 'specs/test_data/drivers_test.csv'

describe "TripDispatcher class" do
  describe "Initializer" do
    it "is an instance of TripDispatcher" do
      dispatcher = RideShare::TripDispatcher.new(USER_TEST_FILE,
                                                 TRIP_TEST_FILE,
                                               DRIVER_TEST_FILE)
      expect(dispatcher).must_be_kind_of RideShare::TripDispatcher
    end

    it "establishes the base data structures when instantiated" do
      dispatcher = RideShare::TripDispatcher.new
      [:trips, :passengers].each do |prop|
        expect(dispatcher).must_respond_to prop
      end

      expect(dispatcher.trips).must_be_kind_of Array
      expect(dispatcher.passengers).must_be_kind_of Array
      expect(dispatcher.drivers).must_be_kind_of Array
    end
  end

  describe "find_user method" do
    before do
      @dispatcher = RideShare::TripDispatcher.new
    end

    it "throws an argument error for a bad ID" do
      expect{ @dispatcher.find_passenger(0) }.must_raise ArgumentError
    end

    it "finds a user instance" do
      passenger = @dispatcher.find_passenger(2)
      expect(passenger).must_be_kind_of RideShare::User
    end
  end

  describe "find_driver method" do
    before do
      @dispatcher = RideShare::TripDispatcher.new(USER_TEST_FILE,
                                                TRIP_TEST_FILE,
                                                DRIVER_TEST_FILE)
    end

    it "throws an argument error for a bad ID" do
      expect { @dispatcher.find_driver(0) }.must_raise ArgumentError
    end

    it "finds a driver instance" do
      driver = @dispatcher.find_driver(2)
      expect(driver).must_be_kind_of RideShare::Driver
    end
  end

  describe "Driver & Trip loader methods" do
    before do
      @dispatcher = RideShare::TripDispatcher.new(USER_TEST_FILE,
                                                 TRIP_TEST_FILE,
                                               DRIVER_TEST_FILE)
    end

    it "accurately loads driver information into drivers array" do
      first_driver = @dispatcher.drivers.first
      last_driver = @dispatcher.drivers.last

      expect(first_driver.name).must_equal "Driver2"
      expect(first_driver.id).must_equal 2
      expect(first_driver.status).must_equal :UNAVAILABLE
      expect(last_driver.name).must_equal "User3"
      expect(last_driver.id).must_equal 3
      expect(last_driver.status).must_equal :AVAILABLE
    end

    it "Connects drivers with trips" do
      trips = @dispatcher.trips

      [trips.first, trips.last].each do |trip|
        driver = trip.driver
        expect(driver).must_be_instance_of RideShare::Driver
        expect(driver.trips).must_include trip
      end
    end
  end

  describe "User & Trip loader methods" do
    before do
      @dispatcher = RideShare::TripDispatcher.new(USER_TEST_FILE,
                                                  TRIP_TEST_FILE,
                                                DRIVER_TEST_FILE)
    end

    it "accurately loads passenger information into passengers array" do
      first_passenger = @dispatcher.passengers.first
      last_passenger = @dispatcher.passengers.last

      expect(first_passenger.name).must_equal "User1"
      expect(first_passenger.id).must_equal 1
      expect(last_passenger.name).must_equal "Driver8"
      expect(last_passenger.id).must_equal 8
    end

    it "accurately loads trip info and associates trips with passengers" do
      trip = @dispatcher.trips.first
      passenger = trip.passenger

      expect(passenger).must_be_instance_of RideShare::User
      expect(passenger.trips).must_include trip
    end
  end
  describe "request trip method" do
    before do
      @dispatcher = RideShare::TripDispatcher.new(USER_TEST_FILE,
                                                  TRIP_TEST_FILE,
                                                DRIVER_TEST_FILE)

      @trips_length = (@dispatcher.trips).length
      @user_id = 2
      @driver_trip = @dispatcher.request_trip(@user_id)
      # binding.pry

    end

    it 'creates a new trip instance' do

      expect(@driver_trip).must_be_kind_of RideShare::Trip
    end

    it "assigns available driver" do
      expect(@driver_trip.driver).must_equal 3
      expect(@driver_trip.driver).wont_equal 2
    end

    # Wave 4 test drafts
    it "will select the driver who has never driven first" do


      expect(@driver_trip.driver).must_equal 3
    end

    it "will select the driver who drove the least recently if there are no drivers with no trips available" do
      @user_id = 7
      @driver_trip = @dispatcher.request_trip(@user_id)

      expect (@driver_trip.driver).must_equal 8
    end

    it "assigns start time as current time" do

      expect(@driver_trip.start_time).must_be_close_to Time.now
    end

    it "returns nil for end time, cost, and rating" do
      expect(@driver_trip.end_time).must_be_nil
      expect(@driver_trip.cost).must_be_nil
      expect(@driver_trip.rating).must_be_nil
    end

    it "creates a new trip in the driver's collection of trips" do
      driver = @dispatcher.drivers.find { |driver| driver.id == 8 }
      expect(driver.driven_trips.length).must_equal 1
      @user_id = 4
      @driver_trip = @dispatcher.request_trip(@user_id)
      expect(@driver_trip.driver).must_equal 8
      expect(driver.driven_trips.length).must_equal 2
    end

    it "converts a driver's status to :UNAVAILABLE when trip in progress" do
      driver = @dispatcher.drivers.find { |driver| driver.id == 3 }
      expect(driver.status).must_equal :UNAVAILABLE
    end

    it "creates a new trip in the user's collection of trips" do
      id = 4
      passenger = @dispatcher.passengers.find { |user| user.id == id }

      expect(passenger.trips.length).must_equal 1
      @driver_trip = @dispatcher.request_trip(id)
      expect(passenger.trips.length).must_equal 2
    end

    it "add a new trip onto the trips array" do
      @trips_length = (@dispatcher.trips).length
      expect(@trips_length).must_equal 7
    end

    it "raises argument error if no drivers are available" do
      @user_id = 4
      @driver_trip = @dispatcher.request_trip(@user_id)
      @user_id = 1
      @driver_trip = @dispatcher.request_trip(@user_id)
      # binding.pry
      expect{@driver_trip = @dispatcher.request_trip(6)}.must_raise ArgumentError
    end

    it "will not accept the passenger and driver to be the same" do
      @user_id = 8
      expect{@driver_trip = @dispatcher.request_trip(@user_id)}.wont_equal 8
    end

  end
end
