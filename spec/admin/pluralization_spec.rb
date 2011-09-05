# encoding: utf-8

require 'spec_helper'

describe "russian pluralization" do
  context "should pluralize properly" do

    def pluralize_model(klass)
      klass.model_name.human.pluralize
    end

    specify { pluralize_model(Order).should == 'Заказы' }
    specify { pluralize_model(Ticket).should == 'Билеты' }
    specify { pluralize_model(OrderComment).should == 'Комментарии к заказу' }
    specify { pluralize_model(Payment).should == 'Платежи' }
    specify { pluralize_model(FlightGroup).should == 'Подборки рейсов' }
    specify { pluralize_model(Destination).should == 'Направления' }
    specify { pluralize_model(HotOffer).should == 'Горячие предложения' }
    specify { pluralize_model(GeoTag).should == 'Геотаги' }
    specify { pluralize_model(Airport).should == 'Аэропорты' }
    specify { pluralize_model(City).should == 'Города' }
    specify { pluralize_model(Region).should == 'Регионы' }
    specify { pluralize_model(Country).should == 'Страны' }
    specify { pluralize_model(AirlineAlliance).should == 'Альянсы авиакомпаний' }
    specify { pluralize_model(GlobalDistributionSystem).should == 'Глобальные дистрибьюторские системы' }
    specify { pluralize_model(Carrier).should == 'Перевозчики' }
    specify { pluralize_model(Consolidator).should == 'Консолидаторы' }
    specify { pluralize_model(Airplane).should == 'Самолеты' }
    specify { pluralize_model(TypusUser).should == 'Пользователи Typus' }

  end
end

