class Paginatior {
  Paginatior(
      {this.currentPage,
      this.previousPage,
      this.nextPage,
      this.itemsPerPage,
      this.total,
      this.startIndex,
      this.endIndex});

  int currentPage;
  int previousPage;
  int nextPage;
  int itemsPerPage;
  int total;
  int startIndex;
  int endIndex;
}
