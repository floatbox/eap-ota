SEARCH & DISPLAY
================

    get session from pool

    get customer input (departure, destination, dates, passengers count)

    # search for recommendations conforming to customer input
    do Fare_TravelBoardSearch

    # search again with the same options and additiona restriction: only nonstop flights
    do Fare_TravelBoardSearch

    # optionally
    do Fare_MasterPricerCalendar

    merge recommendations and filter out some of them according to our business rules

    display recommendations to customer

    return session to pool



SELECT RECOMMENDATION
=====================

    get session from pool

    # check price
    do Fare_InformativePricingWithoutPNR

    if price discrepancy?
      display corrected recommendation, advise customer
      break

    return session to pool

    # bookability check
    create new session

    do Air_SellFromRecommendation

    if unable to sell any segment?
      display error to customer
      break

    display flights details, prices, etc

    logout session


BOOKING
=======

    get and validate passengers data and credit card data

    create new session

    # add itinerary
    do Air_SellFromRecommendation

    if unable to sell any segment?
      display error to customer
      break

    # add passenger name records and commit pnr
    do PNR_AddMultiElements with passengers data and option code for commit/retrieve

    if got errors adding name records, or no PNR number returned on commit
      # cancel PNR itinerary
      do PNR_Cancel with option code for commit
      display error to customer
      break

    # creating tst
    retry block start:

      do Fare_PricePNRWithBookingClass

      if got price discrepancy
      or if last ticket date is too near to process
        do PNR_Cancel with option code for commit
        display error to customer
        break

      do Ticket_CreateTSTFromPricing

      do PNR_AddMultiElements with option code for commit/retrieve
    do PNR_AddMultiElements with code for ignore and retry whole block once on 'SIMULTANEOUS CHANGES TO PNR' error

    # adding passengers passport and bonus cards data
    retry block start:

      for each passenger
          do Command_Cryptic SRDOCS...
          do Command_Cryptic SR FOID...
          do Command_Cryptic FE ...
          do Command_Cryptic FFN ...

      # give access to pnr to ticketing office
      do CommandCryptic ES ...
      do CommandCryptic RP ...

      do PNR_AddMultiElements with option code for commit/retrieve
    do PNR_AddMultiElements with code for ignore and retry whole block once on 'SIMULTANEOUS CHANGES TO PNR' error

    # check again for seat confirmation, some carriers have several second delay before dropping reservation
    do PNR_Retrieve
    if any segment isn't confirmed
      do PNR_Cancel with option code for commit
      display error to customer
      break

    logout session

    if payment authorization on credit card fails
      do PNR_Retrieve for pnr number
      # cancel PNR itinerary
      do PNR_Cancel with option code for commit
      display error to customer
      logout session
      break

    send email with booking details
