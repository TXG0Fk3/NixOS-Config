{ ... }:

{
  services.keyd = {
    enable = true;

    keyboards.default = {
      ids = [ "*" ];

      settings = {
        main = {
          # Tap = Esc, Hold = nav layer
          capslock = "overload(nav, esc)";
        };

        nav = {
          esc = "capslock";
          grave = "esc";

          # Navigation
          w = "up";
          a = "left";
          s = "down";
          d = "right";
          q = "home";
          e = "end";
          r = "pageup";
          f = "pagedown";

          h = "left";
          j = "down";
          k = "up";
          l = "right";

          # Editing
          u = "backspace";
          i = "delete";
          y = "C-backspace";
          p = "C-delete";
          space = "enter";

          # Tabs
          leftbrace = "C-pageup";
          rightbrace = "C-pagedown";

          # Function Keys
          "1" = "f1";
          "2" = "f2";
          "3" = "f3";
          "4" = "f4";
          "5" = "f5";
          "6" = "f6";
          "7" = "f7";
          "8" = "f8";
          "9" = "f9";
          "0" = "f10";
          minus = "f11";
          equal = "f12";
        };
      };
    };
  };
}
