/**
 * Created with JetBrains RubyMine.
 * User: yzhuang
 * Date: 7/23/12
 * Time: 3:36 PM
 * To change this template use File | Settings | File Templates.
 */

$(document).ready(function(){

    rb_today = new Date();
    rb_book_start_day = new Date();
    rb_book_start_day.setDate(rb_book_start_day.getDay() + 30);
    rb_last_day = new Date() ;
    rb_last_day.setDate(rb_last_day.getMonth() + 3) ;

    search_selected_start_date = new Date() ;
    search_selected_end_date = new Date() ;
    search_selected_start_date_str = get_date_str(search_selected_start_date)
    $("#search_alert").hide();
    $("#search_select_start_date").val(search_selected_start_date_str);
    $("#search_select_end_date").val(search_selected_start_date_str);
    $("#new_booking_select_start_date").val(search_selected_start_date_str);
    $("#new_booking_select_end_date").val(search_selected_start_date_str);

    $("#search_select_start_date").datepicker()
        .on('changeDate',function(ev){
            if(ev.date.valueOf() > rb_book_start_day.valueOf()){
                $("#search_alert").show().find("strong").text("You can only check and book the room with start date in 30 days!");
                $("#search_select_start_date").attr("value",search_selected_start_date_str);
                $("#search_select_start_date").datepicker('hide');
            }else if(ev.date.valueOf() < rb_today.valueOf()){
                $("#search_alert").show().find("strong").text("The start date is ealier than today ? ");
                $("#search_select_start_date").attr("value",search_selected_start_date_str);
                $("#search_select_start_date").datepicker('hide');
            }else{
                $("#search_alert").hide();
                search_selected_start_date = new Date(ev.date.valueOf());
                search_selected_start_date_str = get_date_str(search_selected_start_date);
                $("#search_select_end_date").val(search_selected_start_date_str);
                $("#search_select_start_date").datepicker('hide');
            }

        });

    $("#search_select_end_date").datepicker()
        .on('changeDate',function(ev){
            if(ev.date.valueOf() < search_selected_start_date.valueOf()){
                $("#search_alert").show().find("strong").text("The range is invalid, end date should be later than start date!");
                search_selected_start_date_str = get_date_str(search_selected_start_date);
                $("#search_select_end_date").attr("value",search_selected_start_date_str);
            }else if(false){
                // TODO: check the duration between start and end date, it should be less than 3 months
            }else{
                $("#search_alert").hide();
                search_selected_end_date = new Date(ev.date.valueOf())
            }

        });

    $("#confirm_select_start_date").datepicker();

    $("#confirm_select_end_date").datepicker();

    $("#new_booking_select_start_date").datepicker();
    $("#new_booking_select_end_date").datepicker();

    $("#edit_select_start_date").datepicker();
    $("#edit_select_end_date").datepicker();

    $(".alert-info").click(function(){
        $(".search").slideToggle("slow");
    });

    $("input[type=radio].search_recurring_type").change(function(){
        recurring_type = search_get_selected_recurring_type();
        if(recurring_type == 'NO_RECURRING'){
            search_selected_start_date_str = get_date_str(search_selected_start_date);
            $("#search_select_end_date").attr("value",search_selected_start_date_str);
        }else if (recurring_type == 'DAILY'){
            // do nothing
        }else if (recurring_type == 'WEEKLY'){
            // TODO: checking the duration more than one week, if not, just the start date
        }else if (recurring_type == 'BI_WEEKLY'){
            // TODO: same as above
        }else if (recurring_type == 'WORKDAY'){
            // TODO: automated make the checkcbox recurring_days Mon.~Fri. selected
        }

    });

    $(".typeahead").typeahead()



});
