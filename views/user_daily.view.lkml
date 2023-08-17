# The name of this view in Looker is "User Daily"
view: user_daily {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `agolis-allen-first.game_cus.user_daily`
    ;;
  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Game Version" in Explore.

  dimension: game_version {
    type: string
    sql: ${TABLE}.game_version ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
    link: {
      label: "Dashboard for User {{value}} "
      url: "/dashboards/1809?User+ID={{ value | encode_uri }}"
      icon_url: "https://www.seekpng.com/png/full/138-1386046_google-analytics-integration-analytics-icon-blue-png.png"
    }
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: utc {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.utc_date ;;
  }

  dimension: df {
    type: number
    sql: DATE_DIFF(${user_daily.utc_date}, date('1970-01-01'), DAY);;
  }

  dimension:str_month  {
    type: string
    sql: safe_cast(${utc_month} as string) ;;
    order_by_field: df
  }




  dimension: retention_days {
    group_label: "Retention"
    description: "Days since first seen (from event date)"
    type:  number
    sql:  DATE_DIFF(${user_daily.utc_date}, ${users.first_date}, DAY);;
  }

  #new user
  measure: number_of_new_users_V2 {
    type: count_distinct
    sql: ${user_id};;
    filters: {
      field: retention_days
      value: "0"
    }
  }

  # D1

  measure: d1_retained_users {
    group_label: "Retention"
    description: "Number of players that came back to play on day 1"
    type: count_distinct
    sql: ${user_id} ;;
    filters: {
      field: retention_days
      value: "1"
    }
  }

  measure: d1_eligible_users {
    hidden: yes
    group_label: "Retention"
    description: "Number of players older than 0 days"
    type: count_distinct
    sql: ${user_id} ;;
    filters: {
      field: retention_days
      value: "0"
    }
  }

  measure: d1_retention_rate {
    group_label: "Retention"
    description: "% of players (that are older than 0 days) that came back to play on day 1"
    value_format_name: percent_2
    type: number
    sql: 1.0 * ${d1_retained_users}/ NULLIF(${d1_eligible_users},0);;
  }


  measure: d7_retained_users {
    group_label: "Retention"
    description: "Number of players that came back to play on day 7"
    type: count_distinct
    sql: ${user_id} ;;
    filters: {
      field: retention_days
      value: "7"
    }
  }

  measure: d7_retention_rate {
    group_label: "Retention"
    description: "% of players (that are older than 0 days) that came back to play on day 7"
    value_format_name: percent_2
    type: number
    sql: 1.0 * ${d7_retained_users}/ NULLIF(${d1_eligible_users},0);;
  }

  parameter: metrix_selector {
    type: string
    allowed_value: { value: "D1" }
    allowed_value: { value: "D7" }
  }

  measure: retention_rate {
    label_from_parameter: metrix_selector
    group_label: "Retention"
    description: "% of players (that are older than 0 days) that came back to play on day 1 or 7"
    value_format_name: percent_2
    type: number
    sql:
      CASE
       WHEN {% parameter metrix_selector %} = 'D1' THEN ${d1_retention_rate}
       WHEN {% parameter metrix_selector %} = 'D7' THEN ${d7_retention_rate}
       ELSE NULL
      END ;;
  }

  measure: retained_user {
    label_from_parameter: metrix_selector
    group_label: "Retention"
    description: "number  of players (that are older than 0 days) that came back to play on day 1 or 7"
    type: number
    sql:
      CASE
       WHEN {% parameter metrix_selector %} = 'D1' THEN ${d1_retained_users}
       WHEN {% parameter metrix_selector %} = 'D7' THEN ${d7_retained_users}
       ELSE NULL
      END ;;
  }



  measure: count {
    type: count
    drill_fields: []
  }

  measure: count_user {
    label: "Number of user in daily table"
    type: count_distinct
    sql: ${user_id} ;;
    # filters: [game_version: "ios"]
    drill_fields: [utc_date,count_user]
  }

  measure: count_user_1 {
    label: "Number of user in daily table"
    type: count_distinct
    sql: ${user_id} ;;
    filters: {
      field:game_version
      value:"ios"
    }
    drill_fields: [utc_date,count_user]
  }
}
