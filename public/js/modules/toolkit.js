define([], () => {
    "use strict";

    class DOMTools {
        constructor() {
            this.POSSIBLE_EVENTS = [
                ['WebkitTransition', 'webkitTransitionEnd'],
                ['MozTransition', 'transitionend'],
                ['MsTransition', 'msTransitionEnd'],
                ['transition', 'transitionEnd'],
                ['OTransition', 'oTransitionEnd'] // oTransitionEnd in very old Opera
            ];
        }

        matches(node, selector) {
            if (node.nodeType !== 1) {
                return false;
            }
            if (node.matches) {
                return node.matches(selector);
            } else if (node.mozMatchesSelector) {
                return node.mozMatchesSelector(selector);
            } else if (node.msMatchesSelector) {
                return node.msMatchesSelector(selector);
            } else if (node.webkitMatchesSelector) {
                return node.webkitMatchesSelector(selector);
            } else if (node.oMatchesSelector) {
                return node.oMatchesSelector(selector);
            } else {
                throw "Can't match a selector in this browser for " + node + ' of type ' + node.nodeType;
            }
        }

        qsa(node, selector) {
            if (!node.id) {
                node.id = this.genId();
            }
            return node.querySelectorAll('#' + node.id + selector);
        }

        qs(node, selector) {
            const nl = this.qsa(node, selector);
            if (nl.length) {
                return nl.item(0);
            } else {
                return null;
            }
        }

        findAncestor(node, selector) {
            while (node = node.parentNode) {
                if (this.matches(node, selector)) {
                    return node;
                }
            }
            return false;
        }

        nodeListEach(nodeList, fun, thisArg) {
            for (let i = 0; i < nodeList.length; i++) {
                fun.call(thisArg || this, nodeList.item(i));
            }
        }

        descendentsMatching(node, selectors) {
            // fun is either a string or a function returning true or false.
            // fake nodeList.
            const childrenMatching = (ns, s) => {
                const matching = [];
                for (let j = 0; j < ns.length; j++) {
                    const n = ns[j];
                    for (let i = 0; i < n.childNodes.length; i++) {
                        const node = n.childNodes.item(i);
                        if (this.matches(node, s)) {
                            matching.push(node);
                        }
                    }
                }
                return matching;
            }

            let next = [node];
            for (let i = 0; i < selectors.length; i++) {
                next = childrenMatching(next, selectors[i]);
                if (next.length === 0) {
                    break;
                }
            }

            return next;
        }

        childrenMatching(node, selector, thisArg) {
            // fun is either a string or a function returning true or false.
            // fake nodeList.
            const matching = {
                items: [],
                length: 0,
                add: function (item) {
                    this.items.push(item);
                    this.length++;
                },
                item: function (i) {
                    return this.items[i];
                }
            }
            const nodeList = node.children;
            for (let i = 0; i < nodeList.length; i++) {
                const node = nodeList.item(i);
                const matches = this.matches(node, selector);
                if (matches) {
                    matching.add(node);
                }
            }
            return matching;
        }

        firstChildMatching(node, selector, thisArg) {
            const children = this.childrenMatching(node, selector, thisArg);
            if (children.length > 0) {
                return children.item(0);
            } else {
                return null;
            }
        }

        urlPath(url, defaultRoot) {
            const re = new RegExp("http[s]?://([^/]*)(/[^\?#]*)"),
                matches = re.exec(url);
            if (matches) {
                if (matches.length == 3) {
                    const path = matches[2];
                    if (path == "/") {
                        return defaultRoot;
                    } else {
                        return path;
                    }
                }
            } else if (matches.length == 2) {
                return defaultRoot;
            }
        }

        requestURL() {
            const url = window.location.href,
                re = new RegExp(/^([^?]*)(?:\?([^#]*))?(?:\#(.*))?$/),
                parsed = re.exec(url),
                fields = {};
            if (parsed[2]) {
                parsed[2].split("&").forEach(function (field) {
                    const pair = field.split("=");
                    fields[pair[0]] = pair[1];
                });
            }
            return {url: parsed[1], query: fields, queryString: parsed[2], fragment: parsed[3]};
        }

        transitionEndEvent(node) {
            // see: http: / / stackoverflow.com/questions/5023514/how-do-i-normalize-css3-transition-functions-across-browsers
            for (const [testStyle, eventName] of this.POSSIBLE_EVENTS) {
                if (typeof node.style[testStyle] !== 'undefined') {
                    return eventName;
                }
            }
        }

        transitionStyleName(node) {
            // see: http: / / stackoverflow.com/questions/5023514/how-do-i-normalize-css3-transition-functions-across-browsers
            for (const [testStyle, _eventName] of this.POSSIBLE_EVENTS) {
                if (typeof node.style[testStyle] !== 'undefined') {
                    return testStyle;
                }
            }
        }

        onTransitionEnd(node, fun) {
            const event = this.transitionEndEvent(node);
            const handler = function (e) {
                try {
                    fun();
                } catch (e) {
                    console.ERROR('** ERROR ** running handler for onTransitionEnd: ' + e)
                } finally {
                    node.removeEventListener(event, handler, false);
                }
            };
            node.addEventListener(event, handler, false);
        }

        genId() {
            if (this.genIdCounter === undefined) {
                this.genIdCounter = 0;
            }
            this.genIdCounter++;
            return 'genId_' + this.genIdCounter;
        }

        loadCSS(url) {
            const link = document.createElement("link");
            link.type = "text/css";
            link.rel = "stylesheet";
            link.href = url;
            document.getElementsByTagName("head")[0].appendChild(link);
        }
    }

    class Utils {
        nowISO() {
            return Object.create(timezone.Date).init(new Date(), this.TimezoneManager, "Etc/UTC").toISOString();
        }
    }

    return {
        DOMTools,
        Utils
    }
});
