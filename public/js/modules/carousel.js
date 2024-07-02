define(["toolkit"], function (TK) {
  const DOM = new TK.DOMTools();

  const PAUSE_PER_WORD = 250;

  class Carousel {
    constructor(cfg) {
      const config = cfg || {};
      // One master container that contains all the elements --
      this.container = document.querySelector(config.container || ".gallery");

      // The container for gallery items.
      this.itemContainer = this.container.querySelector(
        config.itemContainer || "ul"
      );

      // The gallery items themselves.
      this.items = this.itemContainer.querySelectorAll(config.item || "li");

      this.itemsData = [];

      // The toolbar for buttons / indicators
      this.toolbar = this.container.querySelector(
        config.toolbar || ".-toolbar"
      );

      this.autoPlayInterval = config.interval || 3000;
      this.autoPlay = config.auto || true;

      this.scan();

      return this;
    }

    run() {
      this.currentItemId = 0;
      this.updateItem();
      this.updateToolbar();

      // Auto run...

      if (this.autoPlay) {
        this.startAutoPlay();
      }
      return this;
    }

    scan() {
      let tallest = 0;

      // Review the items
      for (let i = 0; i < this.items.length; i++) {
        const item = this.items.item(i);
        const height = item.offsetHeight;
        if (height > tallest) {
          tallest = height;
        }
        item.setAttribute("data-item", i);
        const text = item.textContent;
        const words = text.split(/\s+/);
        this.itemsData.push({
          wordCount: words.length,
        });
      }

      // And the toolbar.
      const totalHeight = this.toolbar.offsetHeight + tallest;

      this.container.style.height = totalHeight + "px";

      this.itemContainer.style.height = tallest + "px";

      if (this.toolbarPosition === "bottom") {
        this.toolbar.style.top = tallest + "px";
      } else {
        this.itemContainer.style.top = this.toolbar.offsetHeight + "px";
      }

      // Add the item buttons / indicators to the toolbar.
      let toolbarButtons = "";
      toolbarButtons +=
        '<span class="-prev -btn"><i class="fa fa-chevron-left"></i></span>&nbsp;';

      for (let i = 0; i < this.items.length; i++) {
        const btn =
          ' <span class="-item -btn" data-item="' +
          i +
          '"><i class="fa fa-circle"></i></span> ';
        toolbarButtons += btn;
      }
      toolbarButtons +=
        '&nbsp;<span class="-next -btn"><i class="fa fa-chevron-right"></i></span>';
      this.toolbar.innerHTML = toolbarButtons;

      // And then hook up events to them
      // TODO: delegate on the toolbar.
      const btns = this.toolbar.querySelectorAll(".-item.-btn");
      const gallery = this;
      DOM.nodeListEach(btns, function (btn) {
        btn.addEventListener("click", function (e) {
          gallery.onClickSelectBtn(e);
        });
      });

      this.toolbar
        .querySelector(".-prev.-btn")
        .addEventListener("click", function (e) {
          gallery.onClickPrevBtn(e);
        });
      this.toolbar
        .querySelector(".-next.-btn")
        .addEventListener("click", function (e) {
          gallery.onClickNextBtn(e);
        });
    }

    startAutoPlay(tempInterval) {
      const gallery = this;
      // const interval = tempInterval || this.autoPlayInterval;
      const interval =
        this.itemsData[this.currentItemId].wordCount * PAUSE_PER_WORD;

      if (interval) {
        this.autoPlayTimer = window.setTimeout(function () {
          gallery.onAutoPlay();
        }, interval);
      }
    }

    onAutoPlay() {
      this.nextItem();
      if (this.autoPlay) {
        this.startAutoPlay();
      }
    }

    pauseAutoPlay() {
      window.clearTimeout(this.autoPlayTimer);
      this.startAutoPlay(this.autoPlayInterval * 3);
    }

    onClickSelectBtn(e) {
      const b = e.currentTarget;
      const itemId = parseInt(b.getAttribute("data-item"));

      // if on autoplay, have auto play pause for 3x the play rate so that it doesn't
      // just jump away from the selected item.
      if (this.autoPlay) {
        this.pauseAutoPlay();
      }

      this.selectItem(itemId);
    }

    onClickPrevBtn(e) {
      if (this.autoPlay) {
        this.pauseAutoPlay();
      }
      this.prevItem();
    }

    onClickNextBtn(e) {
      if (this.autoPlay) {
        this.pauseAutoPlay();
      }
      this.nextItem();
    }

    prevItem() {
      if (this.currentItemId === 0) {
        this.currentItemId = this.items.length - 1;
      } else {
        this.currentItemId--;
      }
      this.updateItem();
      this.updateToolbar();
    }

    nextItem() {
      if (this.currentItemId === this.items.length - 1) {
        this.currentItemId = 0;
      } else {
        this.currentItemId++;
      }
      this.updateItem();
      this.updateToolbar();
    }

    selectItem(itemId) {
      this.currentItemId = itemId;
      this.updateItem();
      this.updateToolbar();
    }

    updateItem() {
      // make selected item invisible
      const selectedItem = this.itemContainer.querySelector(".-selected");
      if (selectedItem) {
        selectedItem.classList.remove("-selected");
      }

      // make current item visible.
      const currentItem = this.itemContainer.querySelector(
        '[data-item="' + this.currentItemId + '"]'
      );
      currentItem.classList.add("-selected");
    }

    updateToolbar() {
      // unselect previous one
      const selected = this.toolbar.querySelector(".-selected");
      if (selected) {
        selected.classList.remove("-selected");
      }
      const btn = this.toolbar.querySelector(
        '[data-item="' + this.currentItemId + '"]'
      );
      btn.classList.add("-selected");
    }
  }

  return { Carousel };
});
