defmodule Holidex.Countries.CanadaTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  describe "Public API" do
    setup do
      year = Date.utc_today().year
      {:ok, year: year}
    end

    test "holidays/1", context do
      {:ok, holidays} = Holidex.Countries.Canada.holidays(context.year)
      assert length(holidays) == 21
    end

    test "holidays/1 with an invalid year" do
      assert Holidex.Countries.Canada.holidays("2022") ==
               {:error, "Invalid year: 2022. Expected an integer value between 1900 and 2200."}
    end

    test "regions/0" do
      assert length(Holidex.Countries.Canada.regions()) == 13
    end
  end

  describe "All Holidays" do
    setup do
      year = Date.utc_today().year
      {:ok, year: year}
    end

    test "there are 12 public holidays per year nationwide", context do
      {:ok, holidays} =
        Holidex.Countries.Canada.holidays(context.year)

      national_holidays =
        Enum.filter(holidays, &Map.get(&1, :national, false))

      assert length(national_holidays) == 12
    end
  end

  describe "Regional (Provincial) Holidays" do
    setup do
      year = Date.utc_today().year
      {:ok, year: year}
    end

    test "there are 9 public holidays in Alberta", context do
      {:ok, ab_public_holidays} =
        Holidex.Countries.Canada.holidays_by_region(:ab, context.year)

      assert length(ab_public_holidays) == 9
    end

    test "there are 11 public holidays in British Columbia", context do
      {:ok, bc_public_holidays} =
        Holidex.Countries.Canada.holidays_by_region(:bc, context.year)

      assert length(bc_public_holidays) == 11
    end

    test "there are 9 public holidays in Manitoba", context do
      {:ok, mb_public_holidays} =
        Holidex.Countries.Canada.holidays_by_region(:mb, context.year)

      assert length(mb_public_holidays) == 9
    end

    test "there are 7 public holidays in New Brunswick", context do
      {:ok, nb_public_holidays} =
        Holidex.Countries.Canada.holidays_by_region(:nb, context.year)

      assert length(nb_public_holidays) == 9
    end

    test "there are 12 public holidays in Newfoundland and Labrador", context do
      {:ok, nl_public_holidays} =
        Holidex.Countries.Canada.holidays_by_region(:nl, context.year)

      assert length(nl_public_holidays) == 12
    end

    test "there are 11 public holidays in Northwest Territories", context do
      {:ok, nt_public_holidays} =
        Holidex.Countries.Canada.holidays_by_region(:nt, context.year)

      assert length(nt_public_holidays) == 11
    end

    test "there are 10 public holidays in Nunavut", context do
      {:ok, nu_public_holidays} =
        Holidex.Countries.Canada.holidays_by_region(:nu, context.year)

      assert length(nu_public_holidays) == 10
    end

    test "there are 9 public holidays in Ontario", context do
      {:ok, ontario_public_holidays} =
        Holidex.Countries.Canada.holidays_by_region(:on, context.year)

      assert length(ontario_public_holidays) == 9
    end

    test "there are 8 public holidays in PEI", context do
      {:ok, pe_public_holidays} =
        Holidex.Countries.Canada.holidays_by_region(:pe, context.year)

      assert length(pe_public_holidays) == 8
    end

    test "there are 8 public holidays in Québec", context do
      {:ok, qc_public_holidays} =
        Holidex.Countries.Canada.holidays_by_region(:qc, context.year)

      assert length(qc_public_holidays) == 8
    end

    test "there are 10 public holidays in Saskatchewan", context do
      {:ok, sk_public_holidays} =
        Holidex.Countries.Canada.holidays_by_region(:sk, context.year)

      assert length(sk_public_holidays) == 10
    end

    test "there are 11 public holidays in Yukon", context do
      {:ok, yukon_public_holidays} =
        Holidex.Countries.Canada.holidays_by_region(:yt, context.year)

      assert length(yukon_public_holidays) == 11
    end
  end

  describe "Individual Holidays" do
    test "new years day returns the correct values" do
      holiday_name = "New Years Day"

      known_new_years_day_days = %{
        2022 => ~D[2022-01-03],
        2023 => ~D[2023-01-02],
        2024 => ~D[2024-01-01],
        2025 => ~D[2025-01-01],
        2026 => ~D[2026-01-01],
        2027 => ~D[2027-01-01],
        2028 => ~D[2028-01-03],
        2029 => ~D[2029-01-01],
        2030 => ~D[2030-01-01],
        2031 => ~D[2031-01-01],
        2032 => ~D[2032-01-01]
      }

      for {year, expected_date} <- known_new_years_day_days do
        {:ok, holiday} = Holidex.Countries.Canada.holiday(holiday_name, year)
        assert holiday.name == "New Years Day"

        assert holiday.observance_date ==
                 expected_date

        assert holiday.regions_observed == :all
      end
    end

    test "family day returns the correct values" do
      holiday_name = "Family Day"

      known_family_days = %{
        2022 => ~D[2022-02-21],
        2023 => ~D[2023-02-20],
        2024 => ~D[2024-02-19],
        2025 => ~D[2025-02-17],
        2026 => ~D[2026-02-16],
        2027 => ~D[2027-02-15],
        2028 => ~D[2028-02-21],
        2029 => ~D[2029-02-19],
        2030 => ~D[2030-02-18],
        2031 => ~D[2031-02-17]
      }

      for {year, expected_date} <- known_family_days do
        {:ok, holiday} = Holidex.Countries.Canada.holiday(holiday_name, year)
        assert holiday.name == "Family Day"

        assert holiday.observance_date ==
                 expected_date

        assert holiday.regions_observed == [
                 :ab,
                 :bc,
                 :nb,
                 :on,
                 :sk,
                 :mb,
                 :ns,
                 :pe
               ]
      end
    end

    property "family day is always the third Monday in February" do
      check all(year <- StreamData.integer(1900..2100)) do
        {:ok, family_day} = Holidex.Countries.Canada.holiday("Family Day", year)

        assert family_day.date.year == year
        assert family_day.date.month == 2

        # Monday
        assert Date.day_of_week(family_day.date) == 1
        # 3rd Monday always falls in this range
        assert family_day.date.day in 15..21

        # Check it's the 3rd Monday
        first_day_of_month = Date.new!(year, 2, 1)
        days_until_first_monday = rem(1 - Date.day_of_week(first_day_of_month) + 7, 7)
        third_monday = Date.add(first_day_of_month, days_until_first_monday + 14)

        assert family_day.date == third_monday
        assert family_day.observance_date == third_monday
      end
    end

    test "good friday returns the correct values" do
      holiday_name = "Good Friday"

      known_good_fridays = %{
        2022 => ~D[2022-04-15],
        2023 => ~D[2023-04-07],
        2024 => ~D[2024-03-29],
        2025 => ~D[2025-04-18],
        2026 => ~D[2026-04-03],
        2027 => ~D[2027-03-26],
        2028 => ~D[2028-04-14],
        2029 => ~D[2029-03-30],
        2030 => ~D[2030-04-19],
        2031 => ~D[2031-04-11],
        2032 => ~D[2032-03-26]
      }

      for {year, expected_date} <- known_good_fridays do
        {:ok, holiday} = Holidex.Countries.Canada.holiday(holiday_name, year)
        assert holiday.name == "Good Friday"

        assert holiday.observance_date ==
                 expected_date

        assert holiday.regions_observed == :all
      end
    end

    # st_patricks_day
    # easter_sunday
    test "easter monday returns the correct values" do
      holiday_name = "Easter Monday"

      known_easter_monday_dates = %{
        2022 => ~D[2022-04-18],
        2023 => ~D[2023-04-10],
        2024 => ~D[2024-04-01],
        2025 => ~D[2025-04-21],
        2026 => ~D[2026-04-06],
        2027 => ~D[2027-03-29],
        2028 => ~D[2028-04-17],
        2029 => ~D[2029-04-02],
        2030 => ~D[2030-04-22],
        2031 => ~D[2031-04-14],
        2032 => ~D[2032-03-29]
      }

      for {year, expected_date} <- known_easter_monday_dates do
        {:ok, holiday} = Holidex.Countries.Canada.holiday(holiday_name, year)
        assert holiday.name == "Easter Monday"

        assert holiday.date == expected_date

        assert holiday.observance_date ==
                 expected_date

        assert holiday.regions_observed == []
      end
    end

    # st_georges_day

    test "victoria day returns the correct values" do
      holiday_name = "Victoria Day"

      known_victoria_days = %{
        2022 => ~D[2022-05-23],
        2023 => ~D[2023-05-22],
        2024 => ~D[2024-05-20],
        2025 => ~D[2025-05-19],
        2026 => ~D[2026-05-18],
        2027 => ~D[2027-05-24],
        2028 => ~D[2028-05-22],
        2029 => ~D[2029-05-21],
        2030 => ~D[2030-05-20],
        2031 => ~D[2031-05-19],
        2032 => ~D[2032-05-24]
      }

      for {year, expected_date} <- known_victoria_days do
        {:ok, holiday} = Holidex.Countries.Canada.holiday(holiday_name, year)
        assert holiday.name == "Victoria Day"

        assert holiday.observance_date ==
                 expected_date

        assert holiday.regions_observed == [
                 :ab,
                 :bc,
                 :mb,
                 :nb,
                 :nl,
                 :nt,
                 :ns,
                 :nu,
                 :on,
                 :qc,
                 :sk,
                 :yt
               ]
      end
    end

    test "national indigenous peoples day returns the correct values" do
      holiday_name = "National Indigenous Peoples Day"

      known_national_indigenous_peoples_days = %{
        2022 => ~D[2022-06-21],
        2023 => ~D[2023-06-21],
        2024 => ~D[2024-06-21],
        2025 => ~D[2025-06-23],
        2026 => ~D[2026-06-22],
        2027 => ~D[2027-06-21],
        2028 => ~D[2028-06-21],
        2029 => ~D[2029-06-21],
        2030 => ~D[2030-06-21],
        2031 => ~D[2031-06-23],
        2032 => ~D[2032-06-21]
      }

      for {year, expected_date} <- known_national_indigenous_peoples_days do
        {:ok, holiday} = Holidex.Countries.Canada.holiday(holiday_name, year)

        assert holiday.name ==
                 "National Indigenous Peoples Day"

        assert holiday.observance_date ==
                 expected_date

        assert holiday.regions_observed == [:nt, :yt]
      end
    end

    test "saint jean baptiste day returns the correct values" do
      holiday_name = "Saint-Jean-Baptiste Day"

      known_saint_jean_baptiste_days = %{
        2022 => ~D[2022-06-24],
        2023 => ~D[2023-06-26],
        2024 => ~D[2024-06-24],
        2025 => ~D[2025-06-24],
        2026 => ~D[2026-06-24],
        2027 => ~D[2027-06-24],
        2028 => ~D[2028-06-26],
        2029 => ~D[2029-06-25],
        2030 => ~D[2030-06-24],
        2031 => ~D[2031-06-24]
      }

      for {year, expected_date} <- known_saint_jean_baptiste_days do
        {:ok, holiday} = Holidex.Countries.Canada.holiday(holiday_name, year)

        assert holiday.name ==
                 "Saint-Jean-Baptiste Day"

        assert holiday.observance_date ==
                 expected_date

        assert holiday.regions_observed == [
                 :qc
               ]
      end
    end

    test "canada day returns the correct values" do
      holiday_name = "Canada Day"

      known_canada_days = %{
        2022 => ~D[2022-07-01],
        2023 => ~D[2023-07-03],
        2024 => ~D[2024-07-01],
        2025 => ~D[2025-07-01],
        2026 => ~D[2026-07-01],
        2027 => ~D[2027-07-01],
        2028 => ~D[2028-07-03],
        2029 => ~D[2029-07-02],
        2030 => ~D[2030-07-01],
        2031 => ~D[2031-07-01],
        2032 => ~D[2032-07-01]
      }

      for {year, expected_date} <- known_canada_days do
        {:ok, holiday} = Holidex.Countries.Canada.holiday(holiday_name, year)
        assert holiday.name == "Canada Day"

        assert holiday.observance_date ==
                 expected_date

        assert holiday.regions_observed == :all
      end
    end

    # orangemans_day
    test "orangemans day returns the correct values" do
      holiday_name = "Orangeman's Day"

      known_orangemans_day = %{
        2022 => ~D[2022-07-11],
        2023 => ~D[2023-07-10],
        2024 => ~D[2024-07-15],
        2025 => ~D[2025-07-14],
        2026 => ~D[2026-07-13],
        2027 => ~D[2027-07-12],
        2028 => ~D[2028-07-10],
        2029 => ~D[2029-07-09],
        2030 => ~D[2030-07-15],
        2031 => ~D[2031-07-14],
        2032 => ~D[2032-07-12]
      }

      for {year, expected_date} <- known_orangemans_day do
        {:ok, holiday} = Holidex.Countries.Canada.holiday(holiday_name, year)
        assert holiday.name == "Orangeman's Day"

        assert holiday.observance_date ==
                 expected_date

        assert holiday.regions_observed == [:nl]
      end
    end

    # nunavut_day
    test "civic holiday returns the correct values" do
      holiday_name = "Civic Holiday"

      known_civic_holidays = %{
        2022 => ~D[2022-08-01],
        2023 => ~D[2023-08-07],
        2024 => ~D[2024-08-05],
        2025 => ~D[2025-08-04],
        2026 => ~D[2026-08-03],
        2027 => ~D[2027-08-02],
        2028 => ~D[2028-08-07],
        2029 => ~D[2029-08-06],
        2030 => ~D[2030-08-05],
        2031 => ~D[2031-08-04],
        2032 => ~D[2032-08-02]
      }

      for {year, expected_date} <- known_civic_holidays do
        {:ok, holiday} = Holidex.Countries.Canada.holiday(holiday_name, year)
        assert holiday.name == "Civic Holiday"

        assert holiday.observance_date ==
                 expected_date

        assert holiday.regions_observed == [
                 :bc,
                 :nb,
                 :nt,
                 :nu,
                 :sk
               ]
      end
    end

    property "civic holiday is always the first Monday in August" do
      check all(year <- StreamData.integer(1900..2100)) do
        {:ok, civic_holiday} = Holidex.Countries.Canada.holiday("Civic Holiday", year)

        assert civic_holiday.date.year == year
        assert civic_holiday.date.month == 8

        # Monday
        assert Date.day_of_week(civic_holiday.date) == 1
        # 1st Monday always falls in this range
        assert civic_holiday.date.day in 1..7

        # Check it's the 1st Monday
        first_day_of_month = Date.new!(year, 8, 1)
        days_until_first_monday = rem(1 - Date.day_of_week(first_day_of_month) + 7, 7)
        first_monday = Date.add(first_day_of_month, days_until_first_monday)

        assert civic_holiday.date == first_monday
        assert civic_holiday.observance_date == first_monday
      end
    end

    # discovery_day

    test "labour day returns the correct values" do
      holiday_name = "Labour Day"

      known_labour_days = %{
        2022 => ~D[2022-09-05],
        2023 => ~D[2023-09-04],
        2024 => ~D[2024-09-02],
        2025 => ~D[2025-09-01],
        2026 => ~D[2026-09-07],
        2027 => ~D[2027-09-06],
        2028 => ~D[2028-09-04],
        2029 => ~D[2029-09-03],
        2030 => ~D[2030-09-02],
        2031 => ~D[2031-09-01],
        2032 => ~D[2032-09-06]
      }

      for {year, expected_date} <- known_labour_days do
        {:ok, holiday} = Holidex.Countries.Canada.holiday(holiday_name, year)
        assert holiday.name == "Labour Day"

        assert holiday.observance_date ==
                 expected_date

        assert holiday.regions_observed == :all
      end
    end

    property "labour day is always the first Monday in September" do
      check all(year <- StreamData.integer(1900..2100)) do
        {:ok, labour_day} = Holidex.Countries.Canada.holiday("Labour Day", year)

        assert labour_day.date.year == year
        assert labour_day.date.month == 9

        # Monday
        assert Date.day_of_week(labour_day.date) == 1
        # 1st Monday always falls in this range
        assert labour_day.date.day in 1..7

        # Check it's the 1st Monday
        first_day_of_month = Date.new!(year, 9, 1)
        days_until_first_monday = rem(1 - Date.day_of_week(first_day_of_month) + 7, 7)
        first_monday = Date.add(first_day_of_month, days_until_first_monday)

        assert labour_day.date == first_monday
        assert labour_day.observance_date == first_monday
      end
    end

    test "national day for truth and reconciliation returns the correct values" do
      holiday_name = "National Day for Truth and Reconciliation"

      known_national_days_for_truth_and_reconciliation = %{
        2021 => ~D[2021-09-30],
        2022 => ~D[2022-09-30],
        2023 => ~D[2023-10-02],
        2024 => ~D[2024-09-30],
        2025 => ~D[2025-09-30],
        2026 => ~D[2026-09-30],
        2027 => ~D[2027-09-30],
        2028 => ~D[2028-10-02],
        2029 => ~D[2029-10-01],
        2030 => ~D[2030-09-30],
        2031 => ~D[2031-09-30],
        2032 => ~D[2032-09-30]
      }

      for {year, expected_date} <- known_national_days_for_truth_and_reconciliation do
        {:ok, holiday} = Holidex.Countries.Canada.holiday(holiday_name, year)

        assert holiday.name ==
                 "National Day for Truth and Reconciliation"

        assert holiday.observance_date ==
                 expected_date

        assert holiday.regions_observed == [
                 :bc,
                 :nt,
                 :pe,
                 :mb,
                 :yt
               ]
      end
    end

    test "thanksgiving returns the correct values" do
      holiday_name = "Thanksgiving Day"

      known_thanksgivings = %{
        2022 => ~D[2022-10-10],
        2023 => ~D[2023-10-09],
        2024 => ~D[2024-10-14],
        2025 => ~D[2025-10-13],
        2026 => ~D[2026-10-12],
        2027 => ~D[2027-10-11],
        2028 => ~D[2028-10-09],
        2029 => ~D[2029-10-08],
        2030 => ~D[2030-10-14],
        2031 => ~D[2031-10-13],
        2032 => ~D[2032-10-11]
      }

      for {year, expected_date} <- known_thanksgivings do
        {:ok, holiday} = Holidex.Countries.Canada.holiday(holiday_name, year)
        assert holiday.name == "Thanksgiving Day"

        assert holiday.observance_date ==
                 expected_date

        assert holiday.regions_observed == [
                 :ab,
                 :bc,
                 :mb,
                 :nl,
                 :nt,
                 :nu,
                 :on,
                 :qc,
                 :sk,
                 :yt
               ]
      end
    end

    property "thanksgiving is always the second Monday in October" do
      check all(year <- StreamData.integer(1900..2100)) do
        {:ok, thanksgiving} = Holidex.Countries.Canada.holiday("Thanksgiving Day", year)

        assert thanksgiving.date.year == year
        assert thanksgiving.date.month == 10

        # Monday
        assert Date.day_of_week(thanksgiving.date) == 1
        # 2nd Monday always falls in this range
        assert thanksgiving.date.day in 8..14

        # Check it's the 2nd Monday
        first_day_of_month = Date.new!(year, 10, 1)
        days_until_first_monday = rem(1 - Date.day_of_week(first_day_of_month) + 7, 7)
        second_monday = Date.add(first_day_of_month, days_until_first_monday + 7)

        assert thanksgiving.date == second_monday
        assert thanksgiving.observance_date == second_monday
      end
    end

    test "remembrance day returns the correct values" do
      holiday_name = "Remembrance Day"

      known_remembrance_days = %{
        2022 => ~D[2022-11-11],
        2023 => ~D[2023-11-13],
        2024 => ~D[2024-11-11],
        2025 => ~D[2025-11-11],
        2026 => ~D[2026-11-11],
        2027 => ~D[2027-11-11],
        2028 => ~D[2028-11-13],
        2029 => ~D[2029-11-12],
        2030 => ~D[2030-11-11],
        2031 => ~D[2031-11-11],
        2032 => ~D[2032-11-11]
      }

      for {year, expected_date} <- known_remembrance_days do
        {:ok, holiday} = Holidex.Countries.Canada.holiday(holiday_name, year)
        assert holiday.name == "Remembrance Day"

        assert holiday.observance_date ==
                 expected_date

        assert holiday.regions_observed == [
                 :ab,
                 :bc,
                 :nb,
                 :nl,
                 :nt,
                 :nu,
                 :pe,
                 :sk,
                 :yt
               ]
      end
    end

    test "christmas day returns the correct values" do
      holiday_name = "Christmas Day"

      known_christmas_days = %{
        2022 => ~D[2022-12-26],
        2023 => ~D[2023-12-25],
        2024 => ~D[2024-12-25],
        2025 => ~D[2025-12-25],
        2026 => ~D[2026-12-25],
        2027 => ~D[2027-12-27],
        2028 => ~D[2028-12-25],
        2029 => ~D[2029-12-25],
        2030 => ~D[2030-12-25],
        2031 => ~D[2031-12-25],
        2032 => ~D[2032-12-27]
      }

      for {year, expected_date} <- known_christmas_days do
        {:ok, holiday} = Holidex.Countries.Canada.holiday(holiday_name, year)
        assert holiday.name == "Christmas Day"

        assert holiday.observance_date ==
                 expected_date

        assert holiday.regions_observed == :all
      end
    end

    # test "boxing day returns the correct values" do
    #   holiday_name = :boxing_day

    #   known_boxing_days = %{
    #     2020 => ~D[2020-12-28],
    #     2021 => ~D[2021-12-28],
    #     2022 => ~D[2022-12-27],
    #     2023 => ~D[2023-12-26],
    #     2024 => ~D[2024-12-26],
    #     2025 => ~D[2025-12-26],
    #     2026 => ~D[2026-12-28],
    #     2027 => ~D[2027-12-28],
    #     2028 => ~D[2028-12-26],
    #     2029 => ~D[2029-12-26],
    #     2030 => ~D[2030-12-26],
    #     2031 => ~D[2031-12-26],
    #     2032 => ~D[2032-12-28]
    #   }

    #   for {year, expected_date} <- known_boxing_days do
    # {:ok, holiday} = Holidex.Countries.Canada.holiday(holiday_name, year)
    #     assert holiday.name == "Boxing Day"

    #     assert holiday.observance_date ==
    #              expected_date

    #     assert holiday.regions_observed == [
    #              :on,
    #              :nl
    #            ]
    #   end
    # end
  end
end
