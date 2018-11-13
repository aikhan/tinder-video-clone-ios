// Make a company.project namespace
var rh = rh || {};
rh.mq = rh.mq || {};
// My global variable is now restricted and shouldn't collide.
rh.mq.editing = false;

rh.mq.hideNavbar = function() {
	var $navbar = $(".collapse.navbar-collapse"); // .class1.class2 checks to see if it belongs to BOTH class1 and class2.
	if ($navbar.hasClass("in")) {
		$navbar.collapse("hide");
	}
};

rh.mq.enableButtons = function() {
	$("#toggle-edit").click(function() {
		if (rh.mq.editing) {
			rh.mq.editing = false;
			$(".edit-actions").addClass("hidden");
			$(this).html("Edit");
		} else {
			rh.mq.editing = true;
			$(".edit-actions").removeClass("hidden");
			$(this).html("Done");
		}
		rh.mq.hideNavbar();
	});

	$("#add-quote").click(function() {
		// console.log("Clicked add quote");
		$("#insert-quote-modal .modal-title").html("Add a MovieQuote");
		$("#insert-quote-modal button[type=submit]").html("Add Quote");
		// Clear quote field
		$("#insert-quote-modal input[name=quote]").val("");
		// Clear movie field
		$("#insert-quote-modal input[name=movie]").val("");
		// Clear and disable entity key field
		$("#insert-quote-modal input[name=entity_key]").val("").prop("disabled", true);
		rh.mq.hideNavbar();
	});

	$(".edit-movie-quote").click(function() {
		// console.log("Clicked edit quote");
		$("#insert-quote-modal .modal-title").html("Edit this MovieQuote");
		$("#insert-quote-modal button[type=submit]").html("Edit Quote");
		
		// Populate quote field
		quote = $(this).find(".quote").html();
		$("#insert-quote-modal input[name=quote]").val(quote);
		// Populate movie field
		movie = $(this).find(".movie").html();
		$("#insert-quote-modal input[name=movie]").val(movie);
		// Populate and enable entity key field
		entityKey = $(this).find(".entity_key").html();
		console.log("*ENTITY*************" + entityKey)
		$("#insert-quote-modal input[name=entity_key]").val(entityKey).prop("disabled", false);
	});

	$(".delete-movie-quote").click(function() {
		console.log("Clicked delete quote");
		
		// Populate and enable entity key field
		entityKey = $(this).find(".entity_key").html();
		console.log("*DELETE ENTITY*************" + entityKey)
		$("#delete-quote-modal input[name=entity_key]").val(entityKey).prop("disabled", false);
	});

};

rh.mq.addEventHandlers = function() {
	$("#insert-quote-modal").on("shown.bs.modal", function() {
		$("input[name=quote]").focus();
	});
};

$(document).ready(function() {
	rh.mq.enableButtons();
	rh.mq.addEventHandlers();
});
