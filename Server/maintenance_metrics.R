#####################################################################################################################
# login_screen.R - Maintenance_Metrics Source file for Server Module.
# 
# Author: Aravind
# Date: June 13th, 2020
#####################################################################################################################


# Save each metric information into variables.
observe({
  req(input$select_pack)
  if(input$tabs == "mm_tab_value"){
    if(input$select_pack != "Select"){
      
      package_id <- db_fun(paste0("SELECT id
                                  FROM package
                                  WHERE name = ", "'", input$select_pack, "';"))
      
      # Leave method if package not found.
      # TODO: save this to the json file.
      if(nrow(package_id) == 0){
        print("PACKAGE NOT FOUND.")
        return()
      }
      
      # Collect all the metric names and values associated to package_id.
      values$riskmetrics_mm <- db_fun(paste0(
        "SELECT metric.name, package_metrics.value
        FROM metric
        INNER JOIN package_metrics ON metric.id = package_metrics.metric_id
        WHERE package_metrics.package_id = ", "'", package_id, "'", " AND ",
        "metric.class = 'maintenance' ;"))

      runjs("setTimeout(function(){ capturingSizeOfInfoBoxes(); }, 500);")
      
      for(i in 1:nrow(values$riskmetrics_mm))
        values[[values$riskmetrics_mm$name[i]]] <- values$riskmetrics_mm$value[i]
      
      if (values$selected_pkg$decision != "") {
        runjs("setTimeout(function(){disableUI('mm_comment')}, 500);")
        runjs("setTimeout(function(){disableUI('submit_mm_comment')}, 500);")
      }
    }
  }
})

# Render infobox for has_vignettes metric.
output$has_vignettes <- renderInfoBox({
  has_vignettes_infobox(values)
})

# Render infobox for has_website metric.
output$has_website <- renderInfoBox({
  has_website_infobox(values)
})

# Render infobox for has_news metric.
output$has_news <- renderInfoBox({
  has_news_infobox(values)
})

# Render infobox for news_current metric.
output$news_current <- renderInfoBox({
  news_current_infobox(values)
})

# Render infobox for has_bug_reports_url metric.
output$has_bug_reports_url <- renderInfoBox({
  has_bug_reports_url_infobox(values)
})

# Render infobox for bugs_status metric.
output$bugs_status <- renderInfoBox({
  bugs_status_infobox(values)
})

# Render infobox for export_help metric.
output$export_help <- renderInfoBox({
  export_help_infobox(values)
})

# Render infobox for has_source_control metric.
output$has_source_control <- renderInfoBox({
  has_source_control_infobox(values)
})

# Render infobox for has_maintainer metric.
output$has_maintainer <- renderInfoBox({
  has_maintainer_infobox(values)
})

# Show the comments on the package.
output$mm_commented <- renderText({
  if (values$mm_comment_submitted == "yes" ||
      values$mm_comment_submitted == "no") {
    values$comment_mm1 <-
      db_fun(
        paste0(
          "SELECT user_name, user_role, comment, added_on  FROM Comments WHERE comm_id = '",
          input$select_pack,
          "' AND comment_type = 'mm'"
        )
      )
    values$comment_mm2 <- data.frame(values$comment_mm1 %>% map(rev))
    req(values$comment_mm2$comment)
    values$mm_comment_submitted <- "no"
    paste(
      "<div class='col-sm-12 comment-border-bottom single-comment-div'><i class='fa fa-user-tie fa-4x'></i><h3 class='ml-3'><b class='user-name-color'>",
      values$comment_mm2$user_name,
      "(",
      values$comment_mm2$user_role,
      ")",
      "</b><sub>",
      values$comment_mm2$added_on,
      "</sub></h3><h4 class='ml-3 lh-4'>",
      values$comment_mm2$comment,
      "</h4></div>"
    )
  }
})  # End of the render Output.

# End of the Render Output's'.

values$mm_comment_submitted <- "no"

# Observe event for submit button.

observeEvent(input$submit_mm_comment, {
  if (trimws(input$mm_comment) != "") {
    db_ins(
      paste0(
        "INSERT INTO Comments values('",
        input$select_pack,
        "',",
        "'",
        values$name,
        "'," ,
        "'",
        values$role,
        "',",
        "'",
        input$mm_comment,
        "',",
        "'mm'," ,
        "'",
        TimeStamp(),
        "'"  ,
        ")"
      )
    )
    values$mm_comment_submitted <- "yes"
    updateTextAreaInput(session, "mm_comment", value = "")
    # After comment added to Comments table, update db dash
    values$db_pkg_overview <- update_db_dash()
  }
})  # End of the Observe Event.


# End of the Maintenance_Metrics Source file for Server Module.
