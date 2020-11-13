require 'test_helper'
require 'util'

class SaveSocialDistancingRulesetsTest < SeatsioTestClient

  def test_save_social_distancing_rulesets
    chart = @seatsio.charts.create
    rulesets = {
        "ruleset1" => {
            "name" => "My first ruleset",
            "numberOfDisabledSeatsToTheSides" => 1,
            "disableSeatsInFrontAndBehind" => true,
            "disableDiagonalSeatsInFrontAndBehind" => true,
            "numberOfDisabledAisleSeats" => 2,
            "maxGroupSize" => 1,
            "maxOccupancyAbsolute" => 10,
            "oneGroupPerTable" => true,
            "fixedGroupLayout" => false,
            "disabledSeats" => ["A-1"],
            "enabledSeats" => ["A-2"],
            "index" => 4
        },
        "ruleset2" => {
            "name" => "My second ruleset",
            "fixedGroupLayout" => true,
            "disabledSeats" => ["A-1"],
            "index" => 5
        }
    }

    @seatsio.charts.save_social_distancing_rulesets(chart.key, rulesets)

    retrieved_chart = @seatsio.charts.retrieve(chart.key)
    ruleset1 = Seatsio::SocialDistancingRuleset.rule_based("My first ruleset", index: 4, number_of_disabled_seats_to_the_sides: 1,
                                                           disable_seats_in_front_and_behind: true, disable_diagonal_seats_in_front_and_behind: true,
                                                           number_of_disabled_aisle_seats: 2, max_group_size: 1, max_occupancy_absolute: 10,
                                                           one_group_per_table: true, disabled_seats: ["A-1"], enabled_seats: ["A-2"])
    ruleset2 = Seatsio::SocialDistancingRuleset.fixed("My second ruleset", index: 5, disabled_seats: ["A-1"])
    expected_rulesets = {"ruleset1" => ruleset1, "ruleset2" => ruleset2}
    assert_equal(expected_rulesets, retrieved_chart.social_distancing_rulesets)
  end

end
