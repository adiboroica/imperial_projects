export type ShuffledList<Type> = {
  list: Type[],
  indexCache: number[],
};

export function shuffleList<Type>(list: Type[]): ShuffledList<Type> {
  if (list.length === 0) {
    return {
      list,
      indexCache: []
    };
  }

  // Fisher–Yates shuffle

  let currIndex = list.length;

  // Simulate shuffle on an index list
  const nums = Array.from(Array(list.length).keys());

  while (currIndex != 0) {
    const randomIndex = Math.floor(Math.random() * currIndex);
    currIndex--;

    const buffer = list[randomIndex];
    list[randomIndex] = list[currIndex];
    list[currIndex] = buffer;

    const numBuffer = nums[randomIndex];
    nums[randomIndex] = nums[currIndex];
    nums[currIndex] = numBuffer;
  }

  // Index of which each element in original list has been shuffled to
  const indexCache: number[] = Array(list.length);

  for (let i = 0; i < nums.length; i++) {
    indexCache[nums[i]] = i;
  }

  return {
    list,
    indexCache,
  };
};
