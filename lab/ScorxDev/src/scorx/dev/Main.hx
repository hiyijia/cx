package scorx.dev;

import neko.Lib;
import thx.util.Imports;
import ufront.web.AppConfiguration;
import ufront.web.mvc.MvcApplication;
import ufront.web.mvc.view.ErazorViewEngine;
import ufront.web.mvc.ViewEngines;
import ufront.web.routing.RouteCollection;

class Main 
{
    static function main() 
    {
		ViewEngines.engines.add(new ErazorViewEngine());
		
        Imports.pack("controller", false);
        var config = new AppConfiguration("controller");
        
        var routes = new RouteCollection();
        routes.addRoute("/",    						{ controller : "home", action : "index" } );
        routes.addRoute("/home",    					{ controller : "home", action : "index" } );
        routes.addRoute("/player/{?productId}",    		{ controller : "home", action : "player" } );
        routes.addRoute("/playerjs/{?productId}",    	{ controller : "home", action : "playerjs" } );
        routes.addRoute("/home/index",    				{ controller : "home", action : "index" } );
        routes.addRoute("/media/screen/count/{productId}",    { controller : "media", action : "screenCount" } );
        routes.addRoute("/media/screen/{productId}/{?pageNr}/{?userId}",    { controller : "media", action : "screen" } );
        routes.addRoute("/media",    					{ controller : "media", action : "index" } );
        routes.addRoute("/print",    					{ controller : "print", action : "index" } );
        
        var application = new MvcApplication(config, routes);
        application.execute();
    }
}