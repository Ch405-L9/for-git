/* auto-generated; do not edit */
import React from 'react';
import src from '../../assets/testimonial-03.webp';
type Props = Omit<React.ImgHTMLAttributes<HTMLImageElement>, 'src' | 'alt'> & { alt?: string };
export default function Testimonial03({ alt, ...rest }: Props) {
  return (
    <img
      src={String(src)}
      alt={alt ?? 'Testimonial 03'}
      loading="lazy"
      decoding="async"
      {...rest}
    />
  );
}
