var type = "normal";
var firstTier = 1;
var firstUsed = 0;
var firstItems = [];
var secondTier = 1;
var secondUsed = 0;
var secondItems = [];
var errorHighlightTimer = null;
var originOwner = false;
var destinationOwner = false;
var locked = false;
var ikinciagirlik = 0;
var ikincienvagirlik = 0;
var birincienvagirlik = 0;
var birincienvanter = 0;

var dragging = false;
var origDrag = null;
var draggingItem = null;
var givingItem = null;
var mousedown = false;
var docWidth = document.documentElement.clientWidth;
var docHeight = document.documentElement.clientHeight;
var offset = [153, 97];
var cursorX = docWidth / 2;
var cursorY = docHeight / 2;

var successAudio = document.createElement('audio');
successAudio.controls = false;
successAudio.volume = 0.25;
successAudio.src = './success.wav';

var failAudio = document.createElement('audio');
failAudio.controls = false;
failAudio.volume = 0.1;
failAudio.src = './fail2.wav';

window.addEventListener("message", function (event) {
    if (event.data.action == "display") {
        type = event.data.type;

        if (type === "normal") {
            $('#inventoryTwo').parent().hide();
        } else if (type === "secondary") {
            $('#inventoryTwo').parent().show();
        }
        $('#seize').addClass('hidden');
        $('#steal').addClass('hidden');

        $(".ui").fadeIn();
    } else if (event.data.action == "hide") {
        if (event.data.type == 'secondary') {
            $('#inventoryTwo').parent().hide();
        } else {
            $("#dialog").dialog("close");
            $(".ui").fadeOut();
        }
    } else if (event.data.action == "setItems") {
        firstTier = event.data.invTier;
        originOwner = event.data.invOwner;
        plyId = event.data.plyId;
        itemQList = event.data.QualityList
        itemSList = event.data.SerialList
        inventorySetup(event.data.invOwner, event.data.itemList, event.data.money, event.data.invTier, event.data.plyId);

    if ($('#search').val() !== '') {
           SearchInventory($('#search').val());
        }

    } else if (event.data.action == "setSecondInventoryItems") {
        secondTier = event.data.invTier;
        destinationOwner = event.data.invOwner;
        secondInventorySetup(event.data.invOwner, event.data.itemList, event.data.invTier, event.data.money);

    if ($('#search').val() !== '') {
           SearchInventory($('#search').val());
        }
        
    } else if (event.data.action == "setInfoText") {
        $(".info-div").html(event.data.text);
    } else if (event.data.action == "nearPlayersGive" || event.data.action == "nearPlayersPay") {
        successAudio.play();
        givingItem = event.data.originItem;
        $('.near-players-wrapper').find('.popup-body').html('');
        $.each(event.data.players, function (index, player) {
            $('.near-players-list .popup-body').append(`<div class="player" data-id="${player.id}" data-action="${event.data.action}">${player.id} - ${player.name}</div>`);
        });
        $('.near-players-wrapper').fadeIn();
        EndDragging();
    } else if (event.data.action == 'showSeize') {
        $('#seize').removeClass('hidden')
    } else if (event.data.action == 'showSteal') {
        $('#steal').removeClass('hidden')
    } else if (event.data.action == 'itemUsed') {
        ItemUsed(event.data.alerts);
    } else if (event.data.action == 'showActionBar') {
        ActionBar(event.data.items);
    } else if (event.data.action == 'actionbarUsed') {
        ActionBarUsed(event.data.index);
    } else if (event.data.action == 'unlock') {
        UnlockInventory()
    } else if (event.data.action == 'lock') {
        LockInventory()
    }

});

function formatCurrency(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function EndDragging() {
    $(origDrag).removeClass('orig-dragging');
    $("#use").removeClass("disabled");
    $("#drop").removeClass("disabled");
    $("#give").removeClass("disabled");
    $(draggingItem).remove();
    origDrag = null;
    draggingItem = null;
    dragging = false;
}

function closeInventory() {
    InventoryLog('Kapatıldı');
    EndDragging();
    $('.near-players-wrapper').fadeOut();
    $.post("http://disc-inventoryhud/NUIFocusOff", JSON.stringify({}));
    $('#search').val('');
}

function inventorySetup(invOwner, items, money, invTier, plyId) {
    setupPlayerSlots();
    $('#player-inv-label').html('<b> '+plyId+ ' </b>');
    $('#player-inv-id').html('');
    $('#inventoryOne').data('invOwner', invOwner);
    $('#inventoryOne').data('invTier', invTier);

    $('#cash').html('<img src="img/cash.png" class="moneyIcon"> $' + formatCurrency(money.cash));
    $('#bank').html('<img src="img/bank.png" class="moneyIcon"> $' + formatCurrency(money.bank));
    $('#black_money').html('<img src="img/black_money.png" class="moneyIcon"> $' + formatCurrency(money.black_money));
    birincienvagirlik = 0;
    firstUsed = 0;
    $.each(items, function (index, item) {
        var slot = $('#inventoryOne').find('.slot').filter(function () {
            return $(this).data('slot') === item.slot;
        });
        firstUsed++;
        var slotId = $(slot).data('slot');
        firstItems[slotId] = item;
        birincienvagirlik = birincienvagirlik + firstItems[slotId].limiti * firstItems[slotId].qty
        AddItemToSlot(slot, item);
    });

    $('#player-used').html("Weight: " + birincienvagirlik.toFixed(1));
    $("#inventoryOne > .slot:lt(5) .item").append('<div class="item-keybind"></div>');

    $('#inventoryOne .item-keybind').each(function (index) {
        $(this).html(index + 1);
    })
}

function secondInventorySetup(invOwner, items, invTier, money, plyId) {
    setupSecondarySlots(invOwner);
    $('#other-inv-label').html(secondTier.label);
    $('#other-inv-id').html(invOwner);
    $('#inventoryTwo').data('invOwner', invOwner);
    $('#inventoryTwo').data('invTier', invTier);
    $('#second-title').html(secondTier.label);
    $('#second-cash').html('<img src="img/cash.png" class="moneyIcon"> $' + formatCurrency(money.cash));
    $('#second-black_money').html('<img src="img/black_money.png" class="moneyIcon"> $' + formatCurrency(money.black_money));

    ikinciagirlik = 0;
    secondUsed = 0;
    $.each(items, function (index, item) {
        var slot = $('#inventoryTwo').find('.slot').filter(function () {
            return $(this).data('slot') === item.slot;
        });
        secondUsed++;
        var slotId = $(slot).data('slot');
        secondItems[slotId] = item;
        ikinciagirlik = ikinciagirlik + secondItems[slotId].limiti * secondItems[slotId].qty
        AddItemToSlot(slot, item);
    });

    $('#other-used').html("Weight: " + ikinciagirlik.toFixed(1));
}

function setupPlayerSlots() {
    $('#inventoryOne').html("");
    $('#player-inv-id').html("");
    $('#inventoryOne').removeData('invOwner');
    $('#inventoryOne').removeData('invTier');
    $('#player-max').html(firstTier.weight + '.00');
	birincienvanter = firstTier.weight 
    for (i = 1; i <= (firstTier.slots); i++) {
        $("#inventoryOne").append($('.slot-template').clone());
        $('#inventoryOne').find('.slot-template').data('slot', i);
        $('#inventoryOne').find('.slot-template').data('inventory', 'inventoryOne');
        $('#inventoryOne').find('.slot-template').removeClass('slot-template');
    }
}

function setupSecondarySlots(owner) {
    $('#inventoryTwo').html("");
    $('#other-inv-id').html("");
    $('#inventoryTwo').removeData('invOwner');
    $('#inventoryTwo').removeData('invTier');
    if (secondTier.weight == undefined) {
		$('#other-max').html('Unlimited');
	} else {
		$('#other-max').html(secondTier.weight + '.00');
	}
	ikincienvagirlik = secondTier.weight;
    for (i = 1; i <= (secondTier.slots); i++) {
        $("#inventoryTwo").append($('.slot-template').clone());
        $('#inventoryTwo').find('.slot-template').data('slot', i);
        $('#inventoryTwo').find('.slot-template').data('inventory', 'inventoryTwo');
        $('#inventoryTwo').find('.slot-template').addClass('two');

        if (owner.startsWith("drop") || owner.startsWith("container") || owner.startsWith("car") || owner.startsWith("pd-trash")) {
            $('#inventoryTwo').find('.slot-template').addClass('temporary');
        } else if (owner.startsWith("pv") || owner.startsWith("stash")) {
            $('#inventoryTwo').find('.slot-template').addClass('storage');
        } else if (owner.startsWith("steam")) {
            $('#inventoryTwo').find('.slot-template').addClass('player');
        } else if (owner.startsWith("pd-evidence")) {
            $('#inventoryTwo').find('.slot-template').addClass('evidence');
        }

        $('#inventoryTwo').find('.slot-template').removeClass('slot-template');
    }
}

document.addEventListener('mousemove', function (event) {
    event.preventDefault();
    cursorX = event.clientX;
    cursorY = event.clientY;
    if (dragging) {
        if (draggingItem !== undefined && draggingItem !== null) {
            draggingItem.css('left', (cursorX - offset[0]) + 'px');
            draggingItem.css('top', (cursorY - offset[1]) + 'px');
        }
    }
}, true);

$('#count').on('keyup blur', function (e) {
    if ((e.which == 8 || e.which == undefined || e.which == 0)) {
        e.preventDefault();
    }

    if ($(this).val() == '') {
        $(this).val('0');
    } else {
        $(this).val(parseInt($(this).val()))
    }

    if ($(this).val() < 0) {
        $(this).val('1');
    } else {
        $(this).val(parseInt($(this).val()))
    }
});

$(document).ready(function () {

    $('#inventoryOne, #inventoryTwo').on('contextmenu', '.slot', function (event) {
        itemData = $(this).find('.item').data('item');
        if (itemData == null && !dragging) {
            return
        }
        if (event.shiftKey) {
            if (itemData.usable) {
                if (itemData.qua > 0) {
                    InventoryLog('Using ' + itemData.label + ' and Close ' + itemData.closeUi);
                    $.post("http://disc-inventoryhud/UseItem", JSON.stringify({
                        owner: $(draggingItem).parent().data('invOwner'),
                        slot: $(draggingItem).data('slot'),
                        item: itemData
                    }));
                    successAudio.play();
                }else{
                    failAudio.play();
                }
            } else {
                failAudio.play();
            }
        }
    });    
    
    $('#inventoryOne, #inventoryTwo').on('click', '.slot', function (e) {
        if (locked) {
            return
        }

        itemData = $(this).find('.item').data('item');
        if (itemData == null && !dragging) {
            return
        }
        if (dragging) {
            if ($(this).data('slot') !== undefined && $(origDrag).data('slot') !== $(this).data('slot') || $(this).data('slot') !== undefined && $(origDrag).data('invOwner') !== $(this).parent().data('invOwner')) {
                if ($(this).find('.item').data('item') !== undefined) {
                    AttemptDropInOccupiedSlot(origDrag, $(this), parseInt($("#count").val()))
                } else {
                    AttemptDropInEmptySlot(origDrag, $(this), parseInt($("#count").val()));
                }
            } else {
                successAudio.play();
            }
            EndDragging();
        } else {
            if (itemData !== undefined) {
                // Store a reference because JS is retarded
                origDrag = $(this);
                AddItemToSlot(origDrag, itemData);
                $(origDrag).data('slot', $(this).data('slot'));
                $(origDrag).data('invOwner', $(this).parent().data('invOwner'));
                $(origDrag).addClass('orig-dragging');

                // Clone this shit for dragging
                draggingItem = $(this).clone();
                AddItemToSlot(draggingItem, itemData);
                $(draggingItem).data('slot', $(this).data('slot'));
                $(draggingItem).data('invOwner', $(this).parent().data('invOwner'));
                $(draggingItem).addClass('dragging');

                $(draggingItem).css('pointer-events', 'none');
                $(draggingItem).css('left', (cursorX - offset[0]) + 'px');
                $(draggingItem).css('top', (cursorY - offset[1]) + 'px');
                $('.ui').append(draggingItem);


                if (!itemData.usable) {
                    $("#use").addClass("disabled");
                }

                if (!itemData.giveable) {
                    $("#give").addClass("disabled");
                }

                if (!itemData.canRemove) {
                    $("#drop").addClass("disabled");
                    $("#give").addClass("disabled");
                }
            }
            dragging = true;
        }

    });

    $('.close-ui').click(function (event, ui) {
        closeInventory();
    });

    $('#use').click(function (event, ui) {
        if (dragging) {
            itemData = $(draggingItem).find('.item').data("item");
            if (itemData.usable) {
                if (itemData.qua > 0) {
                    InventoryLog('Using ' + itemData.label + ' and Close ' + itemData.closeUi);
                    $.post("http://disc-inventoryhud/UseItem", JSON.stringify({
                        owner: $(draggingItem).parent().data('invOwner'),
                        slot: $(draggingItem).data('slot'),
                        item: itemData
                    }));
                    if (itemData.closeUi) {
                        closeInventory();
                    }
                    successAudio.play();
                    EndDragging();
                }
            } else {
                failAudio.play();
            }
        }
    });

    $('#search').on('keyup keydown blur', function(e) {
       SearchInventory($(this).val());
    });

    $('#search-reset').on('click', function() {
        SearchInventory('');
        $('#search').val('');
    });

    $("#use").mouseenter(function () {
        if (draggingItem != null && !$(this).hasClass('disabled')) {
            $(this).addClass('hover');
        }
    }).mouseleave(function () {
        $(this).removeClass('hover');
    });

    $("#take").mouseenter(function () {
        $(this).addClass('hover');
    }).mouseleave(function () {
        $(this).removeClass('hover');
    }).click(function (event, ui) {
        successAudio.play();
        $('.near-players-wrapper').find('.popup-body').html('');
        $('.near-players-wrapper').find('.popup-body').html('');
        $('.near-players-list .popup-body').append(`<div class="cashtake" data-id="cash">Nakit</div>`);
        $('.near-players-list .popup-body').append(`<div class="cashtake" data-id="black_money">Kara Para</div>`);
        $('.near-players-wrapper').fadeIn();
        EndDragging();
    });

    $("#store").mouseenter(function () {
        $(this).addClass('hover');
    }).mouseleave(function () {
        $(this).removeClass('hover');
    }).click(function (event, ui) {
        successAudio.play();
        $('.near-players-wrapper').find('.popup-body').html('');
        $('.near-players-wrapper').find('.popup-body').html('');
        $('.near-players-list .popup-body').append(`<div class="cashstore" data-id="cash">Nakit</div>`);
        $('.near-players-list .popup-body').append(`<div class="cashstore" data-id="black_money">Kara Para</div>`);
        $('.near-players-wrapper').fadeIn();
        EndDragging();
    });

    $('#give').click(function (event, ui) {
        if (draggingItem != null && dragging) {
            itemData = $(draggingItem).find('.item').data("item");
            let dropCount = parseInt($("#count").val());

            if (dropCount === 0 || dropCount > itemData.qty) {
                dropCount = itemData.qty
            }

            if (itemData.canRemove) {
                $.post("http://disc-inventoryhud/GetNearPlayers", JSON.stringify({
                    originItem: itemData,
                    action: 'give'
                }));

            } else {
                failAudio.play();
            }
        }
    });

    $("#give").mouseenter(function () {
        if (!$(this).hasClass('disabled')) {
            $(this).addClass('hover');
        }
    }).mouseleave(function () {
        $(this).removeClass('hover');
    });

    $("#pay").mouseenter(function () {
        if (!$(this).hasClass('disabled')) {
            $(this).addClass('hover');
        }
    }).mouseleave(function () {
        $(this).removeClass('hover');
    }).click(function (event, ui) {
        successAudio.play();
        $('.near-players-wrapper').find('.popup-body').html('');
        $('.near-players-list .popup-body').append(`<div class="cashchoice" data-id="cash">Nakit</div>`);
        $('.near-players-list .popup-body').append(`<div class="cashchoice" data-id="black_money">Kara Para</div>`);
        $('.near-players-wrapper').fadeIn();
        EndDragging();
    });

    $("#seize").mouseenter(function () {
        if (!$(this).hasClass('disabled')) {
            $(this).addClass('hover');
        }
    }).mouseleave(function () {
        $(this).removeClass('hover');
    }).click(function (event, ui) {
        InventoryLog('Seizing Cash from ' + destinationOwner);
        $.post("http://disc-inventoryhud/SeizeCash", JSON.stringify({
            target: destinationOwner
        }));
    });


    $("#steal").mouseenter(function () {
        if (!$(this).hasClass('disabled')) {
            $(this).addClass('hover');
        }
    }).mouseleave(function () {
        $(this).removeClass('hover');
    }).click(function (event, ui) {
        InventoryLog('Stealing Cash from ' + destinationOwner);
        $.post("http://disc-inventoryhud/StealCash", JSON.stringify({
            target: destinationOwner
        }));
    });

    $('#drop').click(function (event, ui) {
        if (dragging) {
            itemData = $(draggingItem).find('.item').data("item");
            let dropCount = parseInt($("#count").val());

            if (dropCount === 0 || dropCount > itemData.qty) {
                dropCount = itemData.qty
            }

            if (itemData.canRemove) {
                InventoryLog('Dropping ' + dropCount + ' ' + itemData.label + ' On Ground');
                $.post("http://disc-inventoryhud/DropItem", JSON.stringify({
                    item: itemData,
                    qty: dropCount
                }));
                successAudio.play();
            } else {
                failAudio.play();
            }
            EndDragging();
        }
    });

    $("#drop").mouseenter(function () {
        if (!$(this).hasClass('disabled')) {
            $(this).addClass('hover');
        }
    }).mouseleave(function () {
        $(this).removeClass('hover');
    });

    $('#inventoryOne, #inventoryTwo').on('mouseenter', '.slot', function () {
        var itemData = $(this).find('.item').data('item');
        if (itemData !== undefined) {
            $('.tooltip-div').find('.tooltip-name').html(itemData.label);
			var tekilag = itemData.limiti
			var carpim = itemData.limiti * itemData.qty

            if (!itemData.unique) {
                if (itemData.stackable) {
                    $('.tooltip-div').find('.tooltip-uniqueness').html(' - Total weight covered: (' + carpim.toFixed(2) + 'kg)');
                } else {
                    $('.tooltip-div').find('.tooltip-uniqueness').html(' - Total weight covered: (' + carpim.toFixed(2) + 'kg)');
                }
            } else {
                $('.tooltip-div').find('.tooltip-uniqueness').html("Unique (" + itemData.max + ")");
            }
			
			var qualityI = GetItemQualityList(itemData)
			var serialI = GetItemSerialList(itemData)
            if (itemData.description !== undefined) {   	 
    			if (qualityI) {
                	if (serialI) {
						$('.tooltip-div').find('.tooltip-desc').html(itemData.description +'<br /> Serial number: ' + itemData.ser + '<br /> Durability: ' + Number(itemData.qua.toFixed(2)));
					} else {
						$('.tooltip-div').find('.tooltip-desc').html(itemData.description + '<br /> Durability: ' + Number(itemData.qua.toFixed(2)));
					}
				} else {
					if (serialI) {
						$('.tooltip-div').find('.tooltip-desc').html(itemData.description +'<br /> Serial number: ' + itemData.ser);
					} else {
						$('.tooltip-div').find('.tooltip-desc').html(itemData.description);
					}
				}
            } else {
            	if (qualityI) { 
					if (serialI) {
						$('.tooltip-div').find('.tooltip-desc').html('The item does not have any information <br /> Serial number: ' + itemData.ser + '<br /> Durability: ' + Number(itemData.qua.toFixed(1)));
					} else {
						$('.tooltip-div').find('.tooltip-desc').html('The item does not have any information' + '<br /> Durability: ' + Number(itemData.qua.toFixed(1)));
					}
				} else {
					if (serialI) {
						$('.tooltip-div').find('.tooltip-desc').html('The item does not have any information <br /> Serial number: ' + itemData.ser);
					} else {
						$('.tooltip-div').find('.tooltip-desc').html('The item does not have any information');
					}
				}
            }

            if (itemData.limiti !== undefined) {
                $('.tooltip-div').find('.tooltip-weight').html('Weight: ' + itemData.limiti * itemData.qty);
            } else {
                $('.tooltip-div').find('.tooltip-weight').hide()
            }

            if (itemData.staticMeta !== undefined || itemData.staticMeta !== "") {
                if (itemData.type === 1) {
                    $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-entry"><div class="meta-key">Registered Owner</div> : <div class="meta-val">' + itemData.staticMeta.owner + '</div></div>');
                } else if (itemData.itemId === 'license') {
                    $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-entry"><div class="meta-key">Name</div> : <div class="meta-val">' + itemData.staticMeta.name + '</div></div>');
                    $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-entry"><div class="meta-key">Issued On</div> : <div class="meta-val">' + itemData.staticMeta.issuedDate + '</div></div>');
                    $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-entry"><div class="meta-key">Height</div> : <div class="meta-val">' + itemData.staticMeta.height + '</div></div>');
                    $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-entry"><div class="meta-key">Date of Birth</div> : <div class="meta-val">' + itemData.staticMeta.dob + '</div></div>');
                    $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-entry"><div class="meta-key">Phone Number</div> : <div class="meta-val">' + itemData.staticMeta.phone + '</div></div>');
                    $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-entry"><div class="meta-key">Citizen ID</div> : <div class="meta-val">' + itemData.staticMeta.id + '-' + itemData.staticMeta.user + '</div></div>');

                    if (itemData.staticMeta.endorsements !== undefined) {
                        $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-entry"><div class="meta-key">Endorsement</div> : <div class="meta-val">' + itemData.staticMeta.endorsements + '</div></div>');
                    }
                } else if (itemData.itemId === 'gold') {
                    $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-entry"><div class="meta-key"></div> : <div class="meta-val">This Bar Has A Serial Number Engraved Into It Registered To San Andreas Federal Reserve</div></div>');
                }
            } else {
                $('.tooltip-div').find('.tooltip-meta').html("This Item Has No Information");
            }
            $('.tooltip-div').show();
        }
    });

    $('#inventoryOne, #inventoryTwo').on('mouseleave', '.slot', function () {
        $('.tooltip-div').hide();
        $('.tooltip-div').find('.tooltip-name').html("");
        $('.tooltip-div').find('.tooltip-uniqueness').html("");
        $('.tooltip-div').find('.tooltip-meta').html("");
    });

    $("body").on("keyup", function (key) {
        if (Config.closeKeys.includes(key.which)) {
            closeInventory();
        }

        if (key.which === 69) {
            if (type === "trunk") {
                closeInventory();
            }
        }
    });
});

$('.popup-body').on('click', '.cashchoice', function () {
    $.post("http://disc-inventoryhud/GetNearPlayers", JSON.stringify({
        action: 'pay',
        originItem: $(this).data("id")
    }));
});

$('.popup-body').on('click', '.cashstore', function () {
    $.post("http://disc-inventoryhud/CashStore", JSON.stringify({
        action: 'cashstore',
        item: $(this).data("id"),
        count: parseInt($("#count").val()),
        owner: destinationOwner,
        destinationTier: secondTier
    }), function(status){
        $('.near-players-wrapper').fadeOut();
    });
});

$('.popup-body').on('click', '.cashtake', function () {
    $.post("http://disc-inventoryhud/CashTake", JSON.stringify({
        action: 'cashtake',
        item: $(this).data("id"),
        count: parseInt($("#count").val()),
        owner: destinationOwner,
        destinationTier: secondTier
    }), function(status){
        $('.near-players-wrapper').fadeOut();
    });
});

function SearchInventory(searchVal) {
    if (searchVal !== '') {
        $.each(
            $('#search')
                .parent()
                .parent()
                .parent()
                .find('#inventoryOne, #inventoryTwo')
                .children(),
            function(index, slot) {
                let item = $(slot).find('.item').data('item');

                if (item != null) {
                    if (
                        item.label.toUpperCase().includes(searchVal.toUpperCase()) ||
                        item.itemId.includes(searchVal.toUpperCase())
                    ) {
                        $(slot).removeClass('search-non-match');
                    } else {
                        $(slot).addClass('search-non-match');
                    }
                } else {
                    $(slot).addClass('search-non-match');
                }
            }
        );

    } else {
        $.each(
            $('#search')
                .parent()
                .parent()
                .parent()
                .find('#inventoryOne, #inventoryTwo')
                .children(),
            function(index, slot) {
                $(slot).removeClass('search-non-match');
            }
        );
    }
}

function AttemptDropInEmptySlot(origin, destination, moveQty) {
    var result = ErrorCheck(origin, destination, moveQty);
    if (result === -1) {
        $('.slot.error').removeClass('error');
        var item = origin.find('.item').data('item');

        if (item == null) {
            return;
        }

        if (moveQty > item.qty || moveQty === 0) {
            moveQty = item.qty;
        }

        var esyaagirligi = item.limiti * moveQty;
		var envveesyaagirligi = esyaagirligi + birincienvagirlik;
		var sahip 		 = origin.parent().data('invOwner');
		var suruklesahip = destination.parent().data('invOwner');
		var iceriyormu = suruklesahip.includes("steam:"); 
		var ikincienvveesyaagirligi = ikinciagirlik + esyaagirligi;
		var envanteriki = ikincienvagirlik - 1;
		if (envveesyaagirligi > birincienvanter ) {
			if (iceriyormu == true) {
				if (sahip == suruklesahip){
				
				} else {
					return;
				}
			}
		}
		if (ikincienvveesyaagirligi > envanteriki ) {
			if (sahip == suruklesahip){
				var iceriyormu2 = suruklesahip.includes("steam:");
				var sahi23p = sahip.includes("steam:"); 
				if (iceriyormu2 == true) {
					if (sahi23p == true) {
						return;
					}
				}
			} else {
				if (iceriyormu == true)
				{
				} else
				{
					return;
				}
			}
        }	

        if (moveQty === item.qty) {
            ResetSlotToEmpty(origin);
            item.slot = destination.data('slot');
            AddItemToSlot(destination, item);
            successAudio.play();
            InventoryLog('Moving ' + item.qty + ' ' + item.label + ' ' + ' From ' + origin.data('invOwner') + ' Slot ' + origin.data('slot') + ' To ' + destination.parent().data('invOwner') + ' Slot ' + item.slot);
            $.post("http://disc-inventoryhud/MoveToEmpty", JSON.stringify({
                originOwner: origin.parent().data('invOwner'),
                originSlot: origin.data('slot'),
                originTier: origin.parent().data('invTier'),
                originItem: item,
                destinationOwner: destination.parent().data('invOwner'),
                destinationType: destination.find('.item').data('invType'),
                destinationSlot: item.slot,
                destinationTier: destination.parent().data('invTier'),
                destinationItem: destination.find('.item').data('item'),
            }));
            LockInventory();
        } else {
            var item2 = Object.create(item);
            item2.slot = destination.data('slot');
            item2.qty = moveQty;
            item.qty = item.qty - moveQty;
            AddItemToSlot(origin, item);
            AddItemToSlot(destination, item2);
            successAudio.play();

            InventoryLog('Empty: Moving ' + moveQty + ' ' + item.label + ' From ' + origin.data('invOwner') + ' Slot ' + item.slot + ' To ' + destination.parent().data('invOwner') + ' Slot ' + item2.slot);
            $.post("http://disc-inventoryhud/EmptySplitStack", JSON.stringify({
                originOwner: origin.parent().data('invOwner'),
                originSlot: origin.data('slot'),
                originTier: origin.parent().data('invTier'),
                originItem: origin.find('.item').data('item'),
                destinationOwner: destination.parent().data('invOwner'),
                destinationSlot: item2.slot,
                destinationTier: destination.parent().data('invTier'),
                destinationItem: destination.find('.item').data('item'),
                moveQty: moveQty,
            }));
            LockInventory();
        }
    } else {
        failAudio.play();
        if (result === 1) {
            origin.addClass('error');
            setTimeout(function () {
                origin.removeClass('error');
            }, 1000);
            destination.addClass('error');
            setTimeout(function () {
                destination.removeClass('error');
            }, 1000);
            InventoryLog("Destination Inventory Owner Was Undefined");
        }
    }
}

function AttemptDropInOccupiedSlot(origin, destination, moveQty) {
    var result = ErrorCheck(origin, destination, moveQty);

    var originItem = origin.find('.item').data('item');
    var destinationItem = destination.find('.item').data('item');

    if (originItem == undefined || destinationItem == undefined) {
        return;
    }
        if (lmao == lmao2 )
    var lmao = originItem.qua
    var lmao2 = destinationItem.qua

    if (result === -1) {
        $('.slot.error').removeClass('error');
        if (originItem.itemId === destinationItem.itemId && destinationItem.stackable) {
            if (moveQty > originItem.qty || moveQty === 0) {
                moveQty = originItem.qty;
            }
            var esyaagirligi = originItem.limiti * moveQty;
            var envveesyaagirligi = esyaagirligi + birincienvagirlik;
            var sahip 		 = origin.parent().data('invOwner');
            var suruklesahip = destination.parent().data('invOwner');
            var iceriyormu = suruklesahip.includes("steam:"); 
            var ikincienvveesyaagirligi = ikinciagirlik + esyaagirligi;
            var envanteriki = ikincienvagirlik - 1;
            if (envveesyaagirligi > birincienvanter ) {
                if (iceriyormu == true) {
                    if (sahip == suruklesahip){
                    
                    } else {
                        return;
                    }
                }
            }
            if (ikincienvveesyaagirligi > envanteriki ) {
                if (sahip == suruklesahip){
                    var iceriyormu2 = suruklesahip.includes("steam:");
                    var sahi23p = sahip.includes("steam:"); 
                    if (iceriyormu2 == true) {
                        if (sahi23p == true) {
                            return;
                        }
                    }
                } else {
                    if (iceriyormu == true)
                    {
                    } else
                    {
                        return;
                    }
                }
            }
            if (moveQty != originItem.qty && destinationItem.qty + moveQty <= destinationItem.max) {
                originItem.qty -= moveQty;
                destinationItem.qty += moveQty;
                AddItemToSlot(origin, originItem);
                AddItemToSlot(destination, destinationItem);

                successAudio.play();
                InventoryLog('Non-Empty: Moving ' + moveQty + ' ' + originItem.label + ' In ' + origin.data('invOwner') + ' Slot ' + originItem.slot + ' To ' + destination.parent().data('invOwner') + ' Slot' + destinationItem.slot);
                $.post("http://disc-inventoryhud/SplitStack", JSON.stringify({
                    originOwner: origin.parent().data('invOwner'),
                    originTier: origin.parent().data('invTier'),
                    originSlot: originItem.slot,
                    originItem: originItem,
                    destinationOwner: destination.parent().data('invOwner'),
                    destinationSlot: destinationItem.slot,
                    destinationTier: destination.parent().data('invTier'),
                    moveQty: moveQty,
                }));
                LockInventory();
            } else {
                if (destinationItem.qty === destinationItem.max) {
                    destinationItem.slot = origin.data('slot');
                    originItem.slot = destination.data('slot');

                    ResetSlotToEmpty(origin);
                    AddItemToSlot(origin, destinationItem);
                    ResetSlotToEmpty(destination);
                    AddItemToSlot(destination, originItem);
                    successAudio.play();
                    InventoryLog('Swapping ' + originItem.label + ' In  ' + destination.parent().data('invOwner') + ' Slot ' + originItem.slot + ' With ' + destinationItem.label + ' In ' + origin.data('invOwner') + ' Slot ' + destinationItem.slot);
                    $.post("http://disc-inventoryhud/SwapItems", JSON.stringify({
                        originOwner: origin.parent().data('invOwner'),
                        originItem: origin.find('.item').data('item'),
                        originSlot: origin.data('slot'),
                        originTier: origin.parent().data('invTier'),
                        destinationOwner: destination.parent().data('invOwner'),
                        destinationItem: destination.find('.item').data('item'),
                        destinationSlot: destination.data('slot'),
                        destinationTier: destination.parent().data('invTier'),
                    }));
                    LockInventory();
                } else if (originItem.qty + destinationItem.qty <= destinationItem.max) {
                    ResetSlotToEmpty(origin);
                    destinationItem.qty += originItem.qty;
                    AddItemToSlot(destination, destinationItem);

                    successAudio.play();
                    InventoryLog('Merging Stack Of ' + originItem.label + ' In ' + origin.data('invOwner') + ' Slot ' + originItem.slot + ' To ' + destination.parent().data('invOwner') + ' Slot' + destinationItem.slot);
                    $.post("http://disc-inventoryhud/CombineStack", JSON.stringify({
                        originOwner: origin.parent().data('invOwner'),
                        originSlot: origin.data('slot'),
                        originTier: origin.parent().data('invTier'),
                        originItem: originItem,
                        originQty: originItem.qty,
                        destinationOwner: destination.parent().data('invOwner'),
                        destinationSlot: destinationItem.slot,
                        destinationQty: destinationItem.qty,
                        destinationTier: destination.parent().data('invTier'),
                        destinationItem: destinationItem,
                    }));
                    LockInventory();
                } else if (destinationItem.qty < destinationItem.max) {
                    var newOrigQty = destinationItem.max - destinationItem.qty;
                    originItem.qty -= newOrigQty;
                    AddItemToSlot(origin, originItem);
                    destinationItem.qty = destinationItem.max;
                    AddItemToSlot(destination, destinationItem);

                    successAudio.play();

                    InventoryLog('Topping Off Stack ' + originItem.label + ' To Existing Stack In Inventory ' + destination.parent().data('invOwner') + ' Slot ' + destinationItem.slot);
                    $.post("http://disc-inventoryhud/TopoffStack", JSON.stringify({
                        originOwner: origin.parent().data('invOwner'),
                        originSlot: origin.data('slot'),
                        originTier: origin.parent().data('invTier'),
                        originItem: originItem,
                        originQty: originItem.qty,
                        destinationOwner: destination.parent().data('invOwner'),
                        destinationSlot: destinationItem.slot,
                        destinationQty: destinationItem.qty,
                        destinationTier: destination.parent().data('invTier'),
                        destinationItem: destinationItem,
                    }));
                    LockInventory();
                } else {
                    DisplayMoveError(origin, destination, "Stack At Max Items");
                }
            }

        } else {
            var esyaagirligi = destinationItem.limiti * destinationItem.qty;
            var envveesyaagirligi = esyaagirligi + birincienvagirlik;
            var esyaagirligi2 = originItem.limiti * originItem.qty;
            var envveesyaagirligi2 = esyaagirligi2 + birincienvagirlik;
            var sahip 		 = origin.parent().data('invOwner');
            var suruklesahip = destination.parent().data('invOwner');
            var iceriyormu = sahip.includes("steam:");
            var iceriyormu2 = suruklesahip.includes("steam:"); 
            var ikincienvveesyaagirligi = ikinciagirlik + esyaagirligi;
            var envanteriki = ikincienvagirlik - 1;
            if (envveesyaagirligi > birincienvanter ) {
                if (iceriyormu == true) {
                    if (sahip == suruklesahip){
                    
                    } else {
                        return;
                    }
                } else {
                    if (iceriyormu2 == true) {
                        if (sahip == suruklesahip){
                    
                        } else {
                            return;
                        }
                    }
                }
            }
            if (envveesyaagirligi2 > birincienvanter ) {
                if (iceriyormu == true) {
                    if (sahip == suruklesahip){
                    
                    } else {
                        return;
                    }
                } else {
                    if (iceriyormu2 == true) {
                        if (sahip == suruklesahip){
                    
                        } else {
                            return;
                        }
                    }
                }
            } 
            if (ikincienvveesyaagirligi > envanteriki ) {
                if (sahip == suruklesahip){
                    var iceriyormu2 = suruklesahip.includes("steam:");
                    var sahi23p = sahip.includes("steam:"); 
                    if (iceriyormu2 == true) {
                        if (sahi23p == true) {
                            return;
                        }
                    }
                } else {
                    if (iceriyormu == true)
                    {
                    } else
                    {
                        return;
                    }
                }
            }
            destinationItem.slot = origin.data('slot');
            originItem.slot = destination.data('slot');

            ResetSlotToEmpty(origin);
            AddItemToSlot(origin, destinationItem);
            ResetSlotToEmpty(destination);
            AddItemToSlot(destination, originItem);
            successAudio.play();
            InventoryLog('Swapping ' + originItem.label + ' In ' + destination.parent().data('invOwner') + ' Slot ' + originItem.slot + ' With ' + destinationItem.label + ' In ' + origin.data('invOwner') + ' Slot ' + destinationItem.slot);
            $.post("http://disc-inventoryhud/SwapItems", JSON.stringify({
                originOwner: origin.parent().data('invOwner'),
                originItem: origin.find('.item').data('item'),
                originSlot: origin.data('slot'),
                originTier: origin.parent().data('invTier'),
                destinationOwner: destination.parent().data('invOwner'),
                destinationItem: destination.find('.item').data('item'),
                destinationSlot: destination.data('slot'),
                destinationTier: destination.parent().data('invTier'),
            }));
            LockInventory();
        }

        let originInv = origin.parent().data('invOwner');
        let destInv = destination.parent().data('invOwner');
    } else {
        failAudio.play();
        if (result === 1) {
            origin.addClass('error');
            setTimeout(function () {
                origin.removeClass('error');
            }, 1000);
            destination.addClass('error');
            setTimeout(function () {
                destination.removeClass('error');
            }, 1000);
            InventoryLog("Destination Inventory Owner Was Undefined");
        }
    }
}

function ErrorCheck(origin, destination, moveQty) {
    var originOwner = origin.parent().data('invOwner');
    var destinationOwner = destination.parent().data('invOwner');

    if (destinationOwner === undefined) {
        return 1
    }

    var sameInventory = (originOwner === destinationOwner);
    var status = -1;

    if (sameInventory) {
    } else if (originOwner === $('#inventoryOne').data('invOwner') && destinationOwner === $('#inventoryTwo').data('invOwner')) {
        var item = origin.find('.item').data('item');
    } else {
        var item = origin.find('.item').data('item');
    }

    return status
}

function ResetSlotToEmpty(slot) {
    slot.find('.item').addClass('empty-item');
    slot.find('.item').css('background-image', 'none');
    slot.find('.item-count').html(" ");
    slot.find('.item-name').html(" ");
    slot.find('.item').removeData("item");
}

function GetItemQualityList(data) {
    var checkUndefined = itemQList[data.id]
    if (checkUndefined == undefined) {
        return false;
    } else {
        var returnv = itemQList[data.id].QualityUse
        return returnv;
    }
}

function GetItemSerialList(data) {
    var checkUndefined = itemSList[data.id]
    if (checkUndefined == undefined) {
        return false;
    } else {
        var returnv = itemSList[data.id].SerialUse
        return returnv;
    }
}

function AddItemToSlot(slot, data) {
    slot.find('.empty-item').removeClass('empty-item');
    slot.find('.item').css('background-image', 'url(\'img/items/' + data.itemId + '.png\')');
    if (data.price !== undefined && data.price !== 0) {
        slot.find('.item-price').html('$' + data.price);
    }
	var toplam = data.limiti * data.qty
    slot.find('.item-count').html(data.qty + "(" + toplam.toFixed(1) + ")");
    var qualityI = GetItemQualityList(data)
    if (qualityI) {
        slot.find('.item-qua').css('width', 120);
        slot.find('.item-qua').html(Number(data.qua.toFixed(2)) + "/" + data.maxd);
        if (data.qua > 99) {
            slot.find('.item-qua').css('width', 120)
            slot.find('.item-qua').css('background-color', 'rgba(111,195,111,0.9)'); // yeşil
            slot.find('.item-qua').html("Excellent")
        } else if (data.qua < 100 && data.qua > 80) {
            slot.find('.item-qua').css('width', 100)
            slot.find('.item-qua').css('background-color', 'rgba(111,195,111,0.9)'); // yeşil
        } else if (data.qua < 81 && data.qua > 70) {
            slot.find('.item-qua').css('width', 90);
            slot.find('.item-qua').css('background-color', 'rgba(111,195,111,0.9)'); // Sarı
        } else if (data.qua < 71 && data.qua > 60) {
            slot.find('.item-qua').css('width', 80);
            slot.find('.item-qua').css('background-color', 'rgb(218, 188, 21)'); // Sarı
        } else if (data.qua < 61 && data.qua > 50) {
            slot.find('.item-qua').css('width', 70);
            slot.find('.item-qua').css('background-color', 'rgb(218, 188, 21)'); // sarı
        } else if (data.qua < 51 && data.qua > 40) {
            slot.find('.item-qua').css('width', 60);
            slot.find('.item-qua').css('background-color', 'orange');
        } else if (data.qua < 41 && data.qua > 30) {
            slot.find('.item-qua').css('width', 50);
            slot.find('.item-qua').css('background-color', 'orange');
        } else if (data.qua < 31 && data.qua > 20) {
            slot.find('.item-qua').css('width', 40);
            slot.find('.item-qua').css('background-color', 'orange');
        } else if (data.qua < 21 && data.qua > 10) {
            slot.find('.item-qua').css('width', 20);
            slot.find('.item-qua').css('background-color', 'rgba(151,44,44,0.9)');
        } else if (data.qua >= 0) {
            slot.find('.item-qua').css('width', 120);
            slot.find('.item-qua').css('background-color', 'rgba(151,44,44,0.9)'); // kırmızı
            slot.find('.item-qua').html("USELESS");

        }
    }
    slot.find('.item-name').html(data.label);
    slot.find('.item').data('item', data);
}

function ClearLog() {
    $('.inv-log').html('');
}

function InventoryLog(log) {
    $('.inv-log').html(log + "<br>" + $('.inv-log').html());
}

function DisplayMoveError(origin, destination, error) {
    failAudio.play();
    origin.addClass('error');
    destination.addClass('error');
    if (errorHighlightTimer != null) {
        clearTimeout(errorHighlightTimer);
    }
    errorHighlightTimer = setTimeout(function () {
        origin.removeClass('error');
        destination.removeClass('error');
    }, 1000);

    InventoryLog(error);
}

$('.exit-popup').on('click', function () {
    givingItem = null;
    $('.near-players-wrapper').fadeOut('normal').promise().then(function () {
        $(this).find('.popup-body').html('');
    });
});

$('.popup-body').on('click', '.player', function () {

    let target = $(this).data('id');
    let action = $(this).data('action');
    let count = parseInt($("#count").val());
    if (action === "nearPlayersGive") {

        if (givingItem != null) {
            if (count === 0 || count > givingItem.qty) {
                count = givingItem.qty
            }
            InventoryLog(`Giving ${count} ${givingItem.label} To Nearby Player With Server ID ${target}`);
            $.post("http://disc-inventoryhud/GiveItem", JSON.stringify({
                target: target,
                originItem: givingItem,
                count: count
            }), function (status) {
                if (status) {
                    $('.near-players-wrapper').fadeOut();

                    if (count == givingItem.qty) {
                        ResetSlotToEmpty(givingItem.slot);
                    }

                    givingItem = null;
                }
            });
        }
    } else if (action === "nearPlayersPay") {
        InventoryLog(`Giving ${count} ${givingItem} To Nearby Player With Server ID ${target}`);
        $.post("http://disc-inventoryhud/GiveCash", JSON.stringify({
            target: target,
            item: givingItem,
            count: count
        }), function (status) {
            if (status) {
                $('.near-players-wrapper').fadeOut();
            }
        });
    }
});


var alertTimer = null;

function ItemAdded(alerts) {
    clearTimeout(alertTimer);

    $.each(alerts, function (index, data) {

        var element = $("<div class='added-item-slot' id='added-item-image'><div class='item-bg' style ='background-image: url(img/items/" + data.item.itemId + ".png')'><div class='label'><p><span id='iLabel'>" + data.qty + "x " + data.item.label + "</span></p></div></div></div>");
        $("#added-item").html("");
        $("#added-item").append(element).hide().fadeIn(200);
        setTimeout(function () {
            $(element).fadeOut(200, function () { $(this).remove(); });
        }, 2500);
    });

}

function ItemUsed(alerts) {
    clearTimeout(alertTimer);

    $.each(alerts, function (index, data) {
        
        console.log(data.message + ' ' + data.item.label);
        UseBar(data, data.message)
    });

}

var actionBarTimer = null;

function ActionBar(items, timer) {
    if ($('#action-bar').is(':visible')) {

        for (let i = 0; i < 5; i++) {
            $('#action-bar .slot').removeClass('expired');
            if (items[i] != null) {
                $(`.slot-${i}`).find('.item-count').html(items[i].qty);
                $(`.slot-${i}`).find('.item-name').html(items[i].label);
                $(`.slot-${i}`).find('.item-keybind').html(items[i].slot);
                $(`.slot-${i}`).find('.item').css('background-image', 'url(\'img/items/' + items[i].itemId + '.png\')');
            } else {
                $(`.slot-${i}`).find('.item-count').html('');
                $(`.slot-${i}`).find('.item-name').html('SLOT');
                $(`.slot-${i}`).find('.item-keybind').html(i + 1);
                $(`.slot-${i}`).find('.item').css('background-image', 'none');
            }
        }
    } else {
        $('#action-bar').html('');
        for (let i = 0; i < 5; i++) {
            if (items[i] != null) {
                $('#action-bar').append(`<div class="slot slot-${i}"><div class="item"><div class="item-count">${items[i].qty}</div><div class="item-name">${items[i].label}</div><div class="item-keybind">${items[i].slot}</div></div></div>`);
                $(`.slot-${i}`).find('.item').css('background-image', 'url(\'img/items/' + items[i].itemId + '.png\')');
            } else {
                $('#action-bar').append(`<div class="slot slot-${i}" data-empty="true"><div class="item"><div class="item-count"></div><div class="item-name">SLOT</div><div class="item-keybind">${i + 1}</div></div></div>`);
                $(`.slot-${i}`).find('.item').css('background-image', 'none');
            }
        }

        $('#action-bar').show('slide', {direction: 'up'}, 1, function () {
            actionBarTimer = setTimeout(function () {
                $('#action-bar .slot').addClass('expired');
                $('#action-bar').hide('slide', {direction: 'up'}, 1, function () {
                    $('#action-bar .slot.expired').remove();
                });
            }, timer == null ? 2500 : timer);
        });
    }
}

var usedActionTimer = null;

function ActionBarUsed(index) {
    clearTimeout(usedActionTimer);

    if ($('#action-bar .slot').is(':visible')) {
        if ($(`.slot-${index - 1}`).data('empty') != null) {
            $(`.slot-${index - 1}`).addClass('empty-used');
        } else {
            $(`.slot-${index - 1}`).addClass('used');
        }
        usedActionTimer = setTimeout(function () {
            $(`.slot-${index - 1}`).removeClass('used');
            $(`.slot-${index - 1}`).removeClass('empty-used');
        }, 1000)
    }
}

function LockInventory() {
    locked = true;
    $('#inventoryOne').addClass('disabled');
    $('#inventoryTwo').addClass('disabled');
}

function UnlockInventory() {
    locked = false;
    $('#inventoryOne').removeClass('disabled');
    $('#inventoryTwo').removeClass('disabled');
}

$('#inventoryOne, #inventoryTwo').click(function(e, event, ui) {
        if(e.shiftKey) {
            if (dragging) {
                itemData = $(draggingItem).find('.item').data("item");
                if (itemData.usable) {
                    if (itemData.qua > 0) {
                        InventoryLog('Using ' + itemData.label + ' and Close ' + itemData.closeUi);
                        $.post("http://disc-inventoryhud/UseItem", JSON.stringify({
                            owner: $(draggingItem).parent().data('invOwner'),
                            slot: $(draggingItem).data('slot'),
                            item: itemData
                        }));
                        if (itemData.closeUi) {
                            closeInventory();
                        }
                        successAudio.play();
                        EndDragging()
                    }
                } else {
                    failAudio.play();
                }
            }
        }
    });



    $(document).ready(function () {
        var spamActive = false;
        var toggleFreeze = false;
    
        $('#inventoryTwo').parent().hide();
    
        $('#inventoryOne, #inventoryTwo').on('mouseup', '.slot', function (e) {
            if (!dragging) {
                return
            };
    
            if (dragging) {
                if ($(this).data('slot') !== undefined && $(origDrag).data('slot') !== $(this).data('slot') || $(this).data('slot') !== undefined && $(origDrag).data('invOwner') !== $(this).parent().data('invOwner')) {
                    if ($(this).find('.item').data('item') !== undefined) {
                        let count = parseInt($("#count").val());
                        if (count < 0)
                            return;
                        AttemptDropInOccupiedSlot(origDrag, $(this), count)
                    } else {
                        let count = parseInt($("#count").val());
                        if (count < 0)
                            return;
                        AttemptDropInEmptySlot(origDrag, $(this), count);
                    }
                } else {
                    successAudio.play();
                }
                EndDragging();
            }
        });
        
    
        $(window).keydown(function (e) {
            lastPressedKey = e.which;
    
            if (lastPressedKey === 67) {
                toggleFreeze = !toggleFreeze;
            }
        });
    
        $(window).keyup(function (e) {
            if (e.which === lastPressedKey)
                lastPressedKey = null;
        });
    
        $('.close-ui').click(function (event, ui) {
            closeInventory();
        })
    
        $('#use').mouseup(function () {
            if (dragging) {
                itemData = $(draggingItem).find('.item').data("item");
                if (itemData.usable) {
                    if (itemData.qua > 0) {
                        // InventoryLog('Using ' + itemData.label);
                        $.post("http://disc-inventoryhud/UseItem", JSON.stringify({
                            owner: $(draggingItem).parent().data('invOwner'),
                            slot: $(draggingItem).data('slot'),
                            item: itemData
                        }), function (closeUi) {
                            if (closeUi) {
                                closeInventory();
                            }
                        });
                        successAudio.play();
                    }
                } else {
                    failAudio.play();
                }
                EndDragging();
            }
        });
    
        $("#use").mouseenter(function () {
            if (!$(this).hasClass('disabled')) {
                $(this).addClass('hover');
            }
        }).mouseleave(function () {
            $(this).removeClass('hover');
        });
    
        let closeInv = $("#closeInv");
        closeInv.mouseenter(function () {
            if (!$(this).hasClass('disabled')) {
                $(this).addClass('hover');
            }
        }).mouseleave(function () {
            $(this).removeClass('hover');
        });
    
        closeInv.click(function (event, ui) {
            closeInventory();
        });
    
        $('#inventoryOne, #inventoryTwo').on('mouseenter', '.slot', function () {
            var itemData = $(this).find('.item').data('item');
    
            if (itemData !== undefined && !toggleFreeze) {
                $('.tooltip-div').find('.tooltip-name').html(itemData.label);
            }
        });
    
        $('#inventoryOne, #inventoryTwo').on('mouseleave', '.slot', function () {
            if (!toggleFreeze) {
                $('.tooltip-div').hide();
                $('.tooltip-div').find('.tooltip-name').html("");
            }
        });
    
        $("body").on("keyup", function (key) {
            if (Config.closeKeys.includes(key.which)) {
                closeInventory();
            }
    
            if (key.which === 69) {
                if (type === "trunk") {
                    closeInventory();
                }
            }
        });
    });
    
    function FastDragAndDrop(origin, count) {
}

function RandomGen(length) {
    var result = '';
    var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    var charactersLength = characters.length;
    for (var i = 0; i < length; i++) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    return result;
}

let fadeOut = 0


function UseBar(data, text) {

    if (data.qty == undefined) { data.qty = 1 };

    let htmlstring = ""
    let id = RandomGen(10)
    fadeOut = id
    htmlstring = " <div class='item2' > <div class='UseBarHead'> " + text + " " + data.qty + "x  </div> <div class='itemname2'> " + data.item.label + " </div> <img src='img/items/" + data.item.itemId + ".png' class='itemimage'>  </div>";

    var p = document.getElementById('UseBar');
    var newElement = document.createElement(id);
    newElement.setAttribute('id', id);
    newElement.innerHTML = htmlstring;
    p.prepend(newElement);

    $("#UseBar").fadeIn(1000);

    setTimeout(() => {
        $(newElement).fadeOut(500);
    }, 2500)

    setTimeout(() => {
        if (fadeOut == id) {
            $("#UseBar").fadeOut(350);
        }
        var element = document.getElementById(id);
        element.parentNode.removeChild(element);

    }, 3000)

}