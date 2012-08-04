/**
 * Created with JetBrains RubyMine.
 * User: yzhuang
 * Date: 8/4/12
 * Time: 2:59 PM
 * To change this template use File | Settings | File Templates.
 */



function get_date_str(date){
    date_str = (date.getMonth()+1)+"/"+date.getDate()+"/"+date.getFullYear();
    return date_str;
}