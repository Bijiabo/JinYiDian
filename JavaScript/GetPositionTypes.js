var positionTypeData = [];

var positionClassesContainer = $(".menu_box");
positionClassesContainer.each(function(index,item){
  item = $(item);
  var title = item.find(".menu_main h2").text().trim();
  var subItems = item.find(".menu_sub dl");
  var itemData = [];
  subItems.each(function(index1,subItem){
    subItem = $(subItem);
    var subTitle = subItem.find("dt a").text().trim();
    var subDataArray = [];
    var subData = subItem.find("dd a").each(function(index2,subItem1){
      subItem1 = $(subItem1);
      subDataArray.push(subItem1.text().trim());
    });
    itemData.push({
      title: subTitle,
      data: subDataArray
    });
  });
  positionTypeData.push({
    title: title,
    data: itemData
  });
});

copy(positionTypeData);
