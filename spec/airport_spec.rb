describe Airport do
  let(:plane) { instance_double("Plane") }
  let(:weather) { instance_double("Weather") }
  let(:airport) { Airport.new(:weather_forecast => weather) }

  before do
    allow(plane).to receive(:land).with(an_instance_of(Airport))
    allow(plane).to receive(:take_off)
  end

  context 'when the weather is bad' do
    before { allow(weather).to receive(:stormy?).and_return(true) }

    describe '#land' do
      it 'raises an error' do
        expect { airport.land(plane) }.to raise_error(AirportError, "Weather is stormy, cannot land.")
      end
    end

    describe '#release' do
      it 'raises an error' do
        expect { airport.release(plane) }.to raise_error(AirportError, "Weather is stormy, cannot take off.")
      end
    end
  end

  context 'when the weather is good' do
    before { allow(weather).to receive(:stormy?).and_return(false) }

    describe '#initilize' do

      it 'sets the capacity' do
        airport2 = Airport.new(:capacity => 5)
        expect(airport2.capacity).to eq 5
      end

      it 'sets to the default capacity if not given' do
        expect(airport.capacity).to eq Airport::DEFAULTS[:capacity]
      end
    end

    describe '#land' do

      context 'when the plane is in flight' do
        before { allow(plane).to receive(:flying?).and_return(true) }

        it 'lands a plane' do
          expect(plane).to receive(:land).with(airport)
          airport.land(plane)
        end

        it 'registers plane at the airport' do
          airport.land(plane)
          expect(airport.planes).to include plane
        end
      end

      context 'when the plane is not flying' do
        before { allow(plane).to receive(:flying?).and_return(false) }

        it 'raises an error' do
          expect { airport.land(plane) }.to raise_error(PlaneError, "Plane already on the ground")
          expect(airport.planes).not_to include plane
        end
      end

      context 'when the airport is full' do
        before do
          allow(plane).to receive(:flying?).and_return(true)
          airport.capacity.times { airport.land(plane) }
        end

        it 'raises an error' do
          expect { airport.land(plane) }.to raise_error(AirportError, "Airport full")
        end
      end
    end

    describe '#release' do

      context "when the plane is in the airport" do
        before do
          allow(plane).to receive(:flying?).and_return(true)
          airport.land(plane)
          allow(plane).to receive(:flying?).and_return(false)
        end

        it 'tells the plane to take off' do
          expect(plane).to receive(:take_off)
          airport.release(plane)
        end

        it 'removes plane from its record' do
          airport.release(plane)
          expect(airport.planes).not_to include plane
        end
      end

      context 'when the plane is in another airport' do
        before { allow(plane).to receive(:flying?).and_return(false) }

        it 'raises and error' do
          expect { airport.release(plane) }.to raise_error(AirportError, "Plane not in current airport")
        end
      end

      context 'when the plane is in the air' do
        before { allow(plane).to receive(:flying?).and_return(true) }

        it "raises an error" do
          expect { airport.release(plane) }.to raise_error(PlaneError, "Plane already in-flight")
        end
      end
    end

    describe 'setting the capacity' do
      it 'changes the capacity' do
        airport.capacity = 25
        expect(airport.capacity).to eq 25
      end
    end
  end

end
