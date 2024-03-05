import { LightningElement, api } from 'lwc';

/**
 * A simple paginator UI control for any results pagination.
 *
 * @fires SearchPaginator#previous
 * @fires SearchPaginator#next
 */
export default class SearchPaginator extends LightningElement {
    /**
     * An event fired when the user clicked on the previous page button.
     *
     * Properties:
     *   - Bubbles: false
     *   - Composed: false
     *   - Cancelable: false
     *
     * @event SearchPaginator#previous
     * @type {CustomEvent}
     *
     * @export
     */

    /**
     * An event fired when the user clicked on the next page button.
     *
     * Properties:
     *   - Bubbles: false
     *   - Composed: false
     *   - Cancelable: false
     *
     * @event SearchPaginator#next
     * @type {CustomEvent}
     *
     * @export
     */

    /**
     * The current page number.
     *
     * @type {Number}
     */
    _pageNumber;

    @api
    get pageNumber(){
        return this._pageNumber;
    }

    set pageNumber(value){
        this._pageNumber = value;
        this.setPageNumbers();
    }

    /**
     * The number of items on a page.
     *
     * @type {Number}
     */
    _pageSize;

    @api
    get pageSize(){
        return this._pageSize;
    }

    set pageSize(value){
        this._pageSize = value;
        this.setPageNumbers();
    }

    /**
     * The total number of items in the list.
     *
     * @type {Number}
     */
    _totalItemCount;

    @api
    get totalItemCount(){
        return this._totalItemCount;
    }

    set totalItemCount(value){
        this._totalItemCount = value;
        this.setPageNumbers();
    }

    /**
     * Handles a user request to go to the previous page.
     *
     * @fires SearchPaginator#previous
     * @private
     */
    handlePrevious() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    /**
     * Handles a user request to go to the next page.
     * @fires SearchPaginator#next
     * @private
     */
    handleNext() {
        this.dispatchEvent(new CustomEvent('next'));
    }

    /**
     * Gets the current page number.
     *
     * @type {Number}
     * @readonly
     * @private
     */
    get currentPageNumber() {
        return this.totalItemCount === 0 ? 0 : this.pageNumber;
    }

    /**
     * Gets whether the current page is the first page.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get isFirstPage() {
        return this.pageNumber === 1;
    }

    /**
     * Gets whether the current page is the last page.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get isLastPage() {
        return this.pageNumber >= this.totalPages;
    }

    /**
     * Gets the total number of pages
     *
     * @type {Number}
     * @readonly
     * @private
     */
    get totalPages() {
        return Math.ceil(this.totalItemCount / this.pageSize);
    }

    setPageNumbers(){
        if(!this.totalItemCount || !this.pageNumber || !this.pageSize || this.totalPages <= 0){
            this.pageToShow = [];
            return;
        }
        let pageToShow = [];
        if(this.totalPages <= 5){
            for(let i=1; i<=this.totalPages; i++){
                if(i === this.pageNumber){
                    pageToShow.push({'pageNum':i,'isActive':true,isDotSpace:false});
                }else{
                    pageToShow.push({'pageNum':i,'isActive':false,isDotSpace:false});
                }
            }
        }else if(this.pageNumber === 1 || this.pageNumber ===2 || this.pageNumber === 3){
            pageToShow.push({'pageNum':1,'isActive':this.pageNumber === 1,isDotSpace:false});
            pageToShow.push({'pageNum':2,'isActive':this.pageNumber === 2,isDotSpace:false});
            pageToShow.push({'pageNum':3,'isActive':this.pageNumber === 3,isDotSpace:false});
            pageToShow.push({'pageNum':4,isDotSpace:true});
            pageToShow.push({'pageNum':this.totalPages,'isActive':false,isDotSpace:false});
        }else if(this.pageNumber === this.totalPages - 2 || this.pageNumber === this.totalPages - 1 || this.pageNumber === this.totalPages){
            pageToShow.push({'pageNum':1,'isActive':false,isDotSpace:false});
            pageToShow.push({'pageNum':2,isDotSpace:true});
            pageToShow.push({'pageNum':this.totalPages - 2,'isActive':this.pageNumber === this.totalPages - 2,isDotSpace:false});
            pageToShow.push({'pageNum':this.totalPages - 1,'isActive':this.pageNumber === this.totalPages - 1,isDotSpace:false});            
            pageToShow.push({'pageNum':this.totalPages,'isActive':this.pageNumber === this.totalPages,isDotSpace:false});
        }else{
            pageToShow.push({'pageNum':1,'isActive':false,isDotSpace:false});
            pageToShow.push({'pageNum':2,isDotSpace:true});
            pageToShow.push({'pageNum':this.pageNumber,'isActive':true,isDotSpace:false});
            pageToShow.push({'pageNum':this.pageNumber+1,isDotSpace:true});
            pageToShow.push({'pageNum':this.totalPages,'isActive':false,isDotSpace:false});
        }
        this.pageToShow = pageToShow;
    }
    selectPageHandler(evt){
        this.dispatchEvent(new CustomEvent('pageselect', { detail: parseInt(evt.target.getAttribute("data-num"),10) }));
    }
}