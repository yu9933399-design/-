$(document).ready(function(){
    updateCartCount();
    $(document).on('click','.add-to-cart-btn',function(){
        var dishId=$(this).data('dish-id');var btn=$(this);
        $.post(contextPath+'/cart/add',{dishId:dishId,quantity:1},function(res){
            if(res.success){showToast('已加入购物车!');updateCartCount();btn.addClass('btn-success').removeClass('btn-primary');setTimeout(function(){btn.removeClass('btn-success').addClass('btn-primary')},1000);}
            else if(res.needLogin){window.location.href=contextPath+'/login';}
            else{showToast(res.message);}
        });
    });
    $(document).on('click','.qty-plus',function(){
        var input=$(this).siblings('.qty-input');
        var qty=parseInt(input.val())+1;
        updateCartQuantity($(this).data('cart-id'),qty,input);
    });
    $(document).on('click','.qty-minus',function(){
        var input=$(this).siblings('.qty-input');
        var qty=parseInt(input.val())-1;
        if(qty<1)return;
        updateCartQuantity($(this).data('cart-id'),qty,input);
    });
    $(document).on('click','.remove-item',function(){$.post(contextPath+'/cart/remove',{cartId:$(this).data('cart-id')},function(){location.reload();});});
});

function updateCartQuantity(cartId,qty,input){
    $.post(contextPath+'/cart/update',{cartId:cartId,quantity:qty},function(res){
        if(res.success){
            input.val(qty);
            var row=input.closest('tr');
            var price=parseFloat(row.attr('data-price'));
            row.find('.subtotal').text('\u00a5'+(price*qty).toFixed(2));
            recalcCartTotal();
        }
    });
}

function recalcCartTotal(){
    var total=0;
    $('tbody tr').each(function(){
        var tr=$(this);
        var priceStr=tr.attr('data-price');
        var qtyStr=tr.find('.qty-input').val();
        if(priceStr&&qtyStr){
            var p=parseFloat(priceStr);
            var q=parseInt(qtyStr);
            if(!isNaN(p)&&!isNaN(q)){total+=p*q;}
        }
    });
    var el=$('.cart-total');
    if(el.length){el.text('\u00a5'+total.toFixed(2));}
}

function updateCartCount(){$.get(contextPath+'/cart/count',function(res){$('#cartCount').text(res.count);});}

function showToast(message){var html='<div class="toast-notification"><i class="fas fa-check-circle text-success me-2"></i>'+message+'</div>';$('body').append(html);setTimeout(function(){$('.toast-notification').fadeOut(function(){$(this).remove();})},2000);}
