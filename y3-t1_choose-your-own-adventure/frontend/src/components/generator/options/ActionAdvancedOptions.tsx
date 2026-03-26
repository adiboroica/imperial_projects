import { setDescriptor, setDetails, setStyle } from "../../../store/features/storySlice";
import { useAppDispatch, useAppSelector } from "../../../store/hooks";
import AdvancedOptionArea from "./AdvancedOptionArea";

const ActionAdvancedOptions = () => {

  const dispatch = useAppDispatch();
  const descriptor = useAppSelector((state) => state.story.descriptor);
  const details = useAppSelector((state) => state.story.details);
  const style = useAppSelector((state) => state.story.style);


  return (
    <>
      <AdvancedOptionArea
        name="General theme"
        value={descriptor}
        onChange={(t) => dispatch(setDescriptor(t.currentTarget.value))}
      />

      <AdvancedOptionArea
        name="Important details"
        value={details}
        onChange={(t) => dispatch(setDetails(t.currentTarget.value))}
      />

      <AdvancedOptionArea
        name="Writing style"
        value={style}
        onChange={(t) => dispatch(setStyle(t.currentTarget.value))}
      />
    </>
  );
}

export default ActionAdvancedOptions;