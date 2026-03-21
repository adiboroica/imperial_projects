import { Flex, Stack, Title } from '@mantine/core';
import gsap from 'gsap';
import { MutableRefObject, useEffect, useLayoutEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import GenreDropdown from '../../components/initialInput/GenreDropdown';
import GenreHandler from '../../components/initialInput/GenreHandler';
import { GenreOption } from '../../components/initialInput/GenreOptions';
import { reset, setGoToGenerator } from '../../store/features/storySlice';
import { useAppDispatch, useAppSelector } from '../../store/hooks';
import '../../style/base.css';
import { GENERATOR_PAGE } from '../../utils/pages';


function InitialInputView() {
  const navigate = useNavigate();

  const dispatch = useAppDispatch();
  const goToGenerator = useAppSelector((state) => state.story.goToGenerator);
  const storyId = useAppSelector((state) => state.story.id);

  const [genre, setGenre] = useState<string>(GenreOption.None);


  useEffect(() => {
    if (goToGenerator) {
      dispatch(setGoToGenerator(false));
      navigate(GENERATOR_PAGE + storyId);
    }
  }, [navigate, dispatch, goToGenerator, storyId]);

  // Reset redux state on initial render
  useEffect(() => {
    dispatch(reset());
  }, [dispatch]);


  // Animations
  const stackRef = useRef() as MutableRefObject<HTMLInputElement>;
  // TODO Fix
  const timeline: any = useRef();

  useLayoutEffect(() => {
    let ctx = gsap.context(() => {
      timeline.current = gsap.timeline()
        .set(".initial-title", { opacity: 0, scale: 2 })
        .set("#genre-dropdown", { opacity: 0, display: "none" })
        .set(".generate-button", { opacity: 0, display: "none" })
        .to(".initial-title", { opacity: 1, delay: 0.2 })
        .to(".initial-title", { scale: 1.5, delay: 0.2 })
        .to(".initial-title", { y: -50 }, "<")
        .to("#genre-dropdown", { opacity: 1, display: "initial" })
        .to(".generate-button", { opacity: 1, display: "initial" });
    }, stackRef);

    return () => ctx.revert();
  }, []);

  return (
    <Flex justify="center" id="page-body" className="flex-grow-1">
      <Stack
        justify="center"
        align="center"
        spacing="lg"
        className="container-base"
        mt={120}
        mb={40}
        ref={stackRef}
      >
        <Title order={1} weight={600} className="initial-title">
          Pick a genre to start...
        </Title>

        <div id="genre-dropdown">
          <Stack spacing="md">
            <GenreDropdown genre={genre} setGenre={setGenre} />
          </Stack>
        </div>

        <GenreHandler genre={genre} />
      </Stack>
    </Flex>
  );
}

export default InitialInputView;
