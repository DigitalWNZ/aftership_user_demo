# The name of this view in Looker is "Users"
view: users {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `game_cus.users`
    ;;
  drill_fields: [user_id]
  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: user_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.user_id ;;
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: first {
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
    sql: ${TABLE}.first_date ;;
  }

  dimension:str_month  {
    type: string
    sql: safe_cast(${first_month} as string) ;;
  }


  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "First Game Version" in Explore.

  dimension: first_game_version {
    type: string
    sql: ${TABLE}.first_game_version ;;
  }

  dimension: first_platform {
    type: string
    sql: ${TABLE}.first_platform ;;
  }

  dimension: first_profile {
    type: string
    sql:  1 ;;
    html: The user was first met at  <font style="font-weight: bold; color: #f54242; white-space: pre-line; line-height: 1;"> {{ first_date._rendered_value }} </font>
    with platform <font style="font-weight: normal; color:#5a42f5; white-space: pre-line;"> {{ first_platform._rendered_value }} </font>
    and version <font style="font-weight: normal; color:#5a42f5; white-space: pre-line;"> {{ first_platform._rendered_value }} {{ first_game_version._rendered_value }} </font>;;
  }



  measure: number_of_users {
    description: "Number of users"
    value_format_name: decimal_0
    type: count
    # sql: ${user_id} ;;
    drill_fields: [first_platform,first_game_version,count]
  }

  measure: count {
    type: count
    drill_fields: []
  }

}
