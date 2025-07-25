$(window).on("load", function () {
  "use strict";

  /* ========================================================== */
  /*   Navigation Background Color                              */
  /* ========================================================== */

  $(window).on("scroll", function () {
    if ($(this).scrollTop() > 450) {
      $(".navbar-fixed-top").addClass("opaque");
    } else {
      $(".navbar-fixed-top").removeClass("opaque");
    }
  });

  /* ========================================================== */
  /*   Hide Responsive Navigation On-Click                      */
  /* ========================================================== */

  $(".navbar-nav li a").on("click", function (event) {
    $(".navbar-collapse").collapse("hide");
  });

  /* ========================================================== */
  /*   Navigation Color                                         */
  /* ========================================================== */

  $("#navbarCollapse").onePageNav({
    filter: ":not(.external)",
  });

  /* ========================================================== */
  /*   SmoothScroll                                             */
  /* ========================================================== */

  $(".navbar-nav li a, a.scrool").on("click", function (e) {
    var full_url = this.href;
    var parts = full_url.split("#");
    var trgt = parts[1];
    var target_offset = $("#" + trgt).offset();
    var target_top = target_offset.top;

    $("html,body").animate({ scrollTop: target_top - 92 }, 1000);
    return false;
  });

  /* ========================================================== */
  /*   Register                                                 */
  /* ========================================================== */

  $("#register-form").each(function () {
    var form = $(this);
    //form.validate();
    form.submit(function (e) {
      if (!e.isDefaultPrevented()) {
        jQuery.post(
          this.action,
          {
            names: $('input[name="register_names"]').val(),
            email: $('input[name="register_email"]').val(),
            phone: $('input[name="register_phone"]').val(),
          },
          function (data) {
            form.fadeOut("fast", function () {
              $(this).siblings("p.register_success_box").show();
            });
          },
        );
        e.preventDefault();
      }
    });
  });
});

/* ========================================================== */
/*   Popup-Gallery                                            */
/* ========================================================== */
$(".popup-gallery")
  .find("a.popup1")
  .magnificPopup({
    type: "image",
    gallery: {
      enabled: true,
    },
  });

$(".popup-gallery")
  .find("a.popup2")
  .magnificPopup({
    type: "image",
    gallery: {
      enabled: true,
    },
  });

$(".popup-gallery")
  .find("a.popup3")
  .magnificPopup({
    type: "image",
    gallery: {
      enabled: true,
    },
  });

$(".popup-gallery")
  .find("a.popup4")
  .magnificPopup({
    type: "iframe",
    gallery: {
      enabled: false,
    },
  });

$(".faq-toggle").on("click", function () {
  var icon = $(this).find(".toggle-icon");
  var target = $(this).data("target");
  $(target)
    .on("shown.bs.collapse", function () {
      icon.text("−");
    })
    .on("hidden.bs.collapse", function () {
      icon.text("+");
    });
});

function scrollToForm() {
  const isMobile = window.innerWidth < 768;
  const targetId = isMobile ? "reserve-now-mobile" : "reserve-now-desktop";
  const el = document.getElementById(targetId);
  if (el) {
    el.scrollIntoView({ behavior: "smooth", block: "start" });
  }
}
